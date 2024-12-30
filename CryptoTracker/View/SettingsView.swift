//
//  SettingsView.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 26/12/24.
//

import SwiftUI
import KeychainAccess

struct SettingsView: View {
    
    private enum TestStatus {
        case notInit
        case loading
        case success
        case failure
    }
    
    @State private var apiKey: String = ""
    @State private var testStatus: TestStatus = .notInit
    @State private var vm: MainViewModel
    @State private var showingAlert = false
    @State private var selectedCurrency: String
    @State private var alertMessage: String = ""
    
    init(vm: MainViewModel = MainViewModel()) {
        self.vm = vm
        self.selectedCurrency = vm.currency.currencyRepresentation
    }
    
    func showAlert(message: String) {
        alertMessage = message
        showingAlert = true
    }
    
    var body: some View {
        NavigationView{
            Form {
                Section("API Key") {
                    HStack {
                        SecureField("API Key", text: $apiKey)
                            .autocapitalization(.none)
                            .padding()
                        Button {
                            vm.saveAPIKey(apiKey: apiKey)
                            showAlert(message: "API Key Saved")
                            apiKey = ""
                        } label: {
                            Label("", systemImage: "arrow.down.circle.fill")
                        }
                        .disabled(apiKey.isEmpty)
                        .alert(alertMessage, isPresented: $showingAlert) {
                                    Button("OK", role: .cancel) { }
                                }
                        
                    }
                    Button("Test API Key") {
                        testStatus = .loading
                        Task {
                            if(await vm.testAPIKey()) {
                                testStatus = .success
                            } else {
                                testStatus = .failure
                            }
                        }
                    }
                    HStack{
                        Spacer()
                        switch(testStatus) {
                        case .loading:
                            ProgressView()
                        case.failure:
                            Text("Error")
                                .font(.headline)
                                .foregroundColor(.red)
                        case .success:
                            Text("Success")
                                .font(.headline)
                                .foregroundColor(.green)
                        case .notInit:
                            Text("No test performed").opacity(0.4)
                        }
                        Spacer()
                    }
                    .padding()
                    Button("Delete API Key") {
                        vm.saveAPIKey(apiKey: nil)
                        showAlert(message: "API Key Deleted")
                    }
                    .foregroundStyle(.red)
                }
                Section("Currency") {
                    Picker("Currency", selection: $selectedCurrency) {
                        // Let user pick between well known currencies
                        ForEach(Array(CurrencyInfo.symbols.keys), id: \.self) {
                            Text("\($0) \(CurrencyInfo.symbols[$0]!)")
                        }
                    }
                    .onChange(of: selectedCurrency) {
                        vm.setCurrencyInfo(CurrencyInfo(selectedCurrency))
                    }
                }
            }.navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
