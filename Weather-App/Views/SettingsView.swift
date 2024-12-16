import SwiftUI

struct SettingsView: View {
    @ObservedObject var settingsController: SettingsController
    @State private var inputValue: String = "" // Local input state
    var onClose: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            // Header with Close Button
            HStack {
                Text("Settings")
                    .font(.title2)
                    .bold()
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Refresh Interval Section
            VStack(spacing: 16) {
                Text("Set Refresh Interval (minutes)")
                    .font(.headline)
                
                HStack {
                    TextField("Enter minutes", text: $inputValue)
                        .keyboardType(.numberPad) // Ensure only numbers can be typed
                        .padding()
                        .frame(width: 120)
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(radius: 2)
                    
                    Text("minutes")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }

                Text("Current Interval: \(Int(settingsController.refreshInterval / 60)) minutes")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
            
            // Save Button
            Button(action: {
                saveInterval()
                settingsController.saveRefreshInterval()
                onClose()
            }) {
                Text("Save")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
        }
        .onAppear {
            inputValue = "\(Int(settingsController.refreshInterval / 60))" // Load current value in minutes
        }
        .padding()
        .background(Color.gray.opacity(0.9))
        .cornerRadius(16)
        .shadow(radius: 8)
        .padding()
    }

    // MARK: - Helper Function to Save Interval
    private func saveInterval() {
        if let minutes = Int(inputValue), minutes >= 1 {
            settingsController.refreshInterval = Double(minutes * 60) // Convert to seconds
        } else {
            inputValue = "1" // Reset to minimum if invalid input
            settingsController.refreshInterval = 60.0
        }
    }
}
