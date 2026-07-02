//
// ErrorBannerView.swift
// Lightweight inline error presentation for recoverable user-facing issues.
// Connects to: services/HabitStore.swift, components/HabitListView.swift
// Created: 2026-07-01
//

import SwiftUI

struct ErrorBannerView: View {
  let message: String
  let dismissAction: () -> Void

  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      Image(systemName: "exclamationmark.triangle.fill")
        .foregroundStyle(.orange)

      Text(message)
        .font(.subheadline)
        .multilineTextAlignment(.leading)

      Spacer()

      Button("Dismiss", action: dismissAction)
        .font(.caption.weight(.semibold))
    }
    .padding()
    .background(Color.orange.opacity(0.12))
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .padding(.horizontal)
    .padding(.top, 8)
  }
}
