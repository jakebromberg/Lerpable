//
//  LerpableMacro.swift
//  LerpableMacros
//
//  Macro implementation that generates Lerpable conformance by inspecting
//  stored properties and generating a lerp function that interpolates each.
//  Properties marked with @Stepped use threshold-based switching instead
//  of linear interpolation.
//
//  Created by Jake Bromberg on 01/15/26.
//  Copyright © 2026 WXYC. All rights reserved.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftCompilerPlugin

public struct LerpableMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        // Only works on structs
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw LerpableMacroError.notAStruct
        }

        // Extract stored properties
        let storedProperties = structDecl.memberBlock.members.compactMap { member -> StoredProperty? in
            guard let varDecl = member.decl.as(VariableDeclSyntax.self),
                  varDecl.bindingSpecifier.tokenKind == .keyword(.var),
                  let binding = varDecl.bindings.first,
                  let identifier = binding.pattern.as(IdentifierPatternSyntax.self),
                  !hasComputedAccessor(binding)
            else {
                return nil
            }

            // Check for @Stepped attribute and extract threshold
            let steppedThreshold = extractSteppedThreshold(from: varDecl)

            return StoredProperty(
                name: identifier.identifier.text,
                type: binding.typeAnnotation?.type,
                steppedThreshold: steppedThreshold
            )
        }

        guard !storedProperties.isEmpty else {
            throw LerpableMacroError.noStoredProperties
        }

        // Generate the lerp function body
        let propertyLerps = storedProperties.map { prop in
            if let threshold = prop.steppedThreshold {
                // Stepped interpolation: switch at threshold
                return "\(prop.name): t < \(threshold) ? a.\(prop.name) : b.\(prop.name)"
            } else {
                // Linear interpolation
                return "\(prop.name): .lerp(a.\(prop.name), b.\(prop.name), t: t)"
            }
        }.joined(separator: ",\n                ")

        let extensionDecl: DeclSyntax = """
            extension \(type.trimmed): Lerpable {
                public static func lerp(_ a: Self, _ b: Self, t: Double) -> Self {
                    Self(
                        \(raw: propertyLerps)
                    )
                }
            }
            """

        return [extensionDecl.cast(ExtensionDeclSyntax.self)]
    }

    /// Extracts the threshold value from a @Stepped attribute, if present.
    /// - Returns: The threshold value, or nil if no @Stepped attribute is found.
    private static func extractSteppedThreshold(from varDecl: VariableDeclSyntax) -> Double? {
        for attribute in varDecl.attributes {
            guard let attr = attribute.as(AttributeSyntax.self),
                  let identifier = attr.attributeName.as(IdentifierTypeSyntax.self),
                  identifier.name.text == "Stepped"
            else { continue }

            // Extract threshold argument if present
            if let args = attr.arguments?.as(LabeledExprListSyntax.self),
               let first = args.first,
               first.label?.text == "threshold" {
                // Handle both float and integer literals
                if let floatLiteral = first.expression.as(FloatLiteralExprSyntax.self) {
                    return Double(floatLiteral.literal.text)
                } else if let intLiteral = first.expression.as(IntegerLiteralExprSyntax.self) {
                    return Double(intLiteral.literal.text)
                }
            }

            // Default threshold if no argument provided
            return 0.5
        }
        return nil
    }

    private static func hasComputedAccessor(_ binding: PatternBindingSyntax) -> Bool {
        guard let accessor = binding.accessorBlock else {
            return false
        }

        switch accessor.accessors {
        case .getter:
            return true
        case .accessors(let accessorList):
            // If it has get with a body, it's computed
            for accessor in accessorList {
                if accessor.accessorSpecifier.tokenKind == .keyword(.get),
                   accessor.body != nil {
                    return true
                }
            }
            return false
        }
    }
}

private struct StoredProperty {
    let name: String
    let type: TypeSyntax?
    let steppedThreshold: Double?  // nil = linear, Some = stepped
}

enum LerpableMacroError: Error, CustomStringConvertible {
    case notAStruct
    case noStoredProperties

    var description: String {
        switch self {
        case .notAStruct:
            "@Lerpable can only be applied to structs"
        case .noStoredProperties:
            "@Lerpable requires at least one stored property"
        }
    }
}

// MARK: - Plugin Entry Point

@main
struct LerpablePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        LerpableMacro.self,
        SteppedMacro.self,
    ]
}
