//
//  SteppedMacro.swift
//  LerpableMacros
//
//  Peer macro that marks a property for stepped interpolation. This macro does
//  not generate any code itself — it serves as a marker that @Lerpable detects
//  to generate stepped interpolation logic instead of linear interpolation.
//
//  Created by Jake Bromberg on 01/16/26.
//  Copyright © 2026 WXYC. All rights reserved.
//

import SwiftSyntax
import SwiftSyntaxMacros

/// Peer macro that marks a property for stepped interpolation.
/// Does not generate code itself — serves as a marker for @Lerpable to detect.
public struct SteppedMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // No peers generated — this is purely a marker
        return []
    }
}
