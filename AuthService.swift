//
//  AuthService.swift
//  CYCLEai-Tracker
//
//  Created by Manan Rastogi on 14/09/25.
//

import Foundation
import Combine

@MainActor
class AuthService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: UserDTO?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiClient: APIClient
    private let keychainStorage: KeychainStorage
    
    init(apiClient: APIClient, keychainStorage: KeychainStorage) {
        self.apiClient = apiClient
        self.keychainStorage = keychainStorage
    }
    
    func checkAuthenticationStatus() async {
        if let token = keychainStorage.retrieveJWTToken() {
            apiClient.setAuthToken(token)
            
            let result: Result<UserDTO, APIError> = await apiClient.get("/user/profile")
            
            switch result {
            case .success(let user):
                self.currentUser = user
                self.isAuthenticated = true
            case .failure(let error):
                if case .unauthorized = error {
                    await logout()
                } else {
                    print("Failed to verify auth token: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        let loginRequest = LoginRequestDTO(email: email, password: password)
        let result: Result<AuthResponseDTO, APIError> = await apiClient.post("/auth/login", body: loginRequest)
        
        isLoading = false
        switch result {
        case .success(let authResponse):
            keychainStorage.storeJWTToken(authResponse.token)
            apiClient.setAuthToken(authResponse.token)
            self.currentUser = authResponse.user
            self.isAuthenticated = true
        case .failure(let error):
            self.errorMessage = error.localizedDescription
        }
    }
    
    func register(email: String, password: String, firstName: String?, lastName: String?) async {
        isLoading = true
        errorMessage = nil
        
        let registerRequest = RegisterRequestDTO(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName
        )
        let result: Result<AuthResponseDTO, APIError> = await apiClient.post("/auth/register", body: registerRequest)
        
        isLoading = false
        switch result {
        case .success(let authResponse):
            keychainStorage.storeJWTToken(authResponse.token)
            apiClient.setAuthToken(authResponse.token)
            self.currentUser = authResponse.user
            self.isAuthenticated = true
        case .failure(let error):
            self.errorMessage = error.localizedDescription
        }
    }
    
    func logout() async {
        keychainStorage.deleteJWTToken()
        apiClient.setAuthToken(nil)
        
        self.currentUser = nil
        self.isAuthenticated = false
        self.errorMessage = nil
    }
    
    func updateProfile(firstName: String?, lastName: String?) async {
        guard var userToUpdate = currentUser else { return }
        
        isLoading = true
        errorMessage = nil
        
        userToUpdate.firstName = firstName
        userToUpdate.lastName = lastName
        
        let result: Result<UserDTO, APIError> = await apiClient.put("/user/profile", body: userToUpdate)
        
        isLoading = false
        switch result {
        case .success(let updatedUser):
            self.currentUser = updatedUser
        case .failure(let error):
            self.errorMessage = error.localizedDescription
        }
    }
}
