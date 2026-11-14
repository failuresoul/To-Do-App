//
//  LoginView.swift
//  TodoFirebaseApp
//
//  Created by Developer on 2026-11-14.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel

    @State private var email = ""
    @State private var password = ""
    @State private var resetEmail = ""
    @State private var showingResetAlert = false
    @State private var showingResetConfirmation = false
    @State private var showingErrorAlert = false

    private var isFormValid: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !password.isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.tint)
                            .padding(.bottom, 4)

                        Text("Welcome Back")
                            .font(.largeTitle.bold())

                        Text("Sign in to manage your tasks")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 36)

                    // Input Fields
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Email")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)

                            TextField("name@example.com", text: $email)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .textContentType(.emailAddress)
                                .padding(12)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Password")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)

                            SecureField("Enter your password", text: $password)
                                .textContentType(.password)
                                .padding(12)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }

                        HStack {
                            Spacer()
                            Button("Forgot Password?") {
                                resetEmail = email
                                showingResetAlert = true
                            }
                            .font(.footnote.weight(.medium))
                        }
                    }

                    // Primary Sign In Button
                    Button {
                        Task {
                            await authViewModel.signIn(
                                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                                password: password
                            )
                            if authViewModel.errorMessage != nil {
                                showingErrorAlert = true
                            }
                        }
                    } label: {
                        HStack(spacing: 8) {
                            if authViewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Sign In")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.roundedRectangle(radius: 10))
                    .disabled(!isFormValid || authViewModel.isLoading)

                    // Sign Up NavigationLink
                    HStack(spacing: 4) {
                        Text("Don't have an account?")
                            .foregroundStyle(.secondary)
                        NavigationLink("Sign Up") {
                            SignUpView()
                        }
                        .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                    .padding(.top, 8)
                }
                .padding(.horizontal, 24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .alert("Reset Password", isPresented: $showingResetAlert) {
                TextField("Email address", text: $resetEmail)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                Button("Cancel", role: .cancel) {}
                Button("Send Link") {
                    let trimmedEmail = resetEmail.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmedEmail.isEmpty else { return }
                    Task {
                        await authViewModel.resetPassword(email: trimmedEmail)
                        if authViewModel.errorMessage != nil {
                            showingErrorAlert = true
                        } else {
                            showingResetConfirmation = true
                        }
                    }
                }
            } message: {
                Text("Enter your email address and we'll send you a link to reset your password.")
            }
            .alert("Password Reset Sent", isPresented: $showingResetConfirmation) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Check your inbox at \(resetEmail) for instructions to reset your password.")
            }
            .alert("Authentication Error", isPresented: $showingErrorAlert) {
                Button("OK", role: .cancel) {
                    authViewModel.errorMessage = nil
                }
            } message: {
                Text(authViewModel.errorMessage ?? "An unknown error occurred.")
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
