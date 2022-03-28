// Copyright 2022 Itty Bitty Apps Pty Ltd. See LICENSE file.

import Foundation

extension Diagnostic {
    func formatted<F>(_ format: F) -> F.FormatOutput where F : FormatStyle, F.FormatInput == Self {
        format.format(self)
    }
}
