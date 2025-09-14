//
//  CyclesService.swift
//  CYCLEai-Tracker
//
//  Created by Manan Rastogi on 14/09/25.
//


import Foundation
import Combine

@MainActor
class CyclesService: ObservableObject {
    @Published var cycles: [CycleDTO] = []
    @Published var currentCycle: CycleDTO?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiClient: APIClient
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    func fetchCycles() async {
        isLoading = true
        errorMessage = nil
        
        let result: Result<[CycleDTO], APIError> = await apiClient.get("/cycles")

        isLoading = false
        switch result {
        case .success(let fetchedCycles):
            self.cycles = fetchedCycles
        case .failure(let error):
            self.errorMessage = error.localizedDescription
        }
    }
    
    func fetchCurrentCycle() async {
        let result: Result<CycleDTO, APIError> = await apiClient.get("/cycles/current")

        switch result {
        case .success(let cycle):
            self.currentCycle = cycle
        case .failure(let error):
            // Current cycle might not exist, this is okay
            print("No current cycle found: \(error.localizedDescription)")
            self.currentCycle = nil
        }
    }
    
    func createCycle(startDate: Date, endDate: Date? = nil) async {
        isLoading = true
        errorMessage = nil
        
        let cycleData = CycleDTO(
            id: nil,
            userId: "", // Will be set by server
            startDate: DateUtils.dateToISOString(startDate),
            endDate: endDate != nil ? DateUtils.dateToISOString(endDate!) : nil,
            cycleLength: nil,
            periodLength: nil,
            isComplete: endDate != nil,
            createdAt: nil
        )
        
        let result: Result<CycleDTO, APIError> = await apiClient.post("/cycles", body: cycleData)
        
        isLoading = false
        switch result {
        case .success(let newCycle):
            self.cycles.insert(newCycle, at: 0) // Add to beginning of list
            self.currentCycle = newCycle
        case .failure(let error):
            self.errorMessage = error.localizedDescription
        }
    }
    
    func updateCycle(_ cycle: CycleDTO) async {
        isLoading = true
        errorMessage = nil
        
        guard let cycleId = cycle.id else {
            self.errorMessage = "Invalid cycle ID"
            isLoading = false
            return
        }
        
        let result: Result<CycleDTO, APIError> = await apiClient.put("/cycles/\(cycleId)", body: cycle)

        isLoading = false
        switch result {
        case .success(let updatedCycle):
            // Update in local array
            if let index = cycles.firstIndex(where: { $0.id == cycleId }) {
                cycles[index] = updatedCycle
            }
            
            // Update current cycle if it's the same one
            if currentCycle?.id == cycleId {
                currentCycle = updatedCycle
            }
        case .failure(let error):
            self.errorMessage = error.localizedDescription
        }
    }
    
    func deleteCycle(_ cycleId: String) async {
        isLoading = true
        errorMessage = nil
        
        let result: Result<Void, APIError> = await apiClient.delete("/cycles/\(cycleId)")
        
        isLoading = false
        switch result {
        case .success:
            // Remove from local array
            cycles.removeAll { $0.id == cycleId }
            
            // Clear current cycle if it was deleted
            if currentCycle?.id == cycleId {
                currentCycle = nil
            }
        case .failure(let error):
            self.errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Computed Properties
    
    var averageCycleLength: Double {
        let completedCycles = cycles.filter { $0.isComplete == true && $0.cycleLength != nil }
        guard !completedCycles.isEmpty else { return 28.0 }
        
        let totalLength = completedCycles.compactMap { $0.cycleLength }.reduce(0, +)
        return Double(totalLength) / Double(completedCycles.count)
    }
    
    var averagePeriodLength: Double {
        let periodsWithLength = cycles.compactMap { $0.periodLength }
        guard !periodsWithLength.isEmpty else { return 5.0 }
        
        let totalLength = periodsWithLength.reduce(0, +)
        return Double(totalLength) / Double(periodsWithLength.count)
    }
}
