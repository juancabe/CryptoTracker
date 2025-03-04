//
//  AddAlertView.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 24/12/24.
//

import SwiftUI

struct AddAlertView: View {

    // Enum to represent the state of adding an alert
    enum AddState {
        case notSent
        case sent
        case succcess
        case failure
    }

    @ObservedObject var vm: AlertsViewModel

    @State private var currInfo: CurrencyInfo
    @State private var selectedCurrency: String

    @State private var id: String

    @State private var expirationDate: Date = Date()

    @State private var selectedAlertType: AlertTypes = .VolatilityAlert

    @State private var doubleString: String = ""
    @State private var doubleValid: Bool = false

    @State private var state: AddState = .notSent

    @State private var canEnableNotifs: Bool = false
    @State private var notifsEnabled: Bool = false

    // Initializer to set up initial values
    init(vm: AlertsViewModel) {
        self.vm = vm
        if !vm.ids.isEmpty {
            self.id = vm.ids[0]
        } else {
            self.id = ""
        }

        let cur = CurrencyInfo.symbols.keys.first!

        self.selectedCurrency = cur
        self.currInfo = CurrencyInfo(cur)
    }

    @State private var alertMessage: String = ""
    @State private var showingAlert = false

    // Function to show alert with a message
    func showAlert(message: String) {
        alertMessage = message
        showingAlert = true
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Form {
                    Section("Currency") {
                        Picker("Currency", selection: $selectedCurrency) {
                            // Let user pick between well known currencies
                            ForEach(Array(CurrencyInfo.symbols.keys), id: \.self) {
                                Text("\($0) \(CurrencyInfo.symbols[$0]!)")
                            }
                        }
                        .onChange(of: selectedCurrency) {
                            currInfo = CurrencyInfo(selectedCurrency)
                        }
                    }

                    if !vm.ids.isEmpty {
                        Section("Crypto") {
                            Picker("Crypto ID", selection: $id) {
                                // Let user pick between well known currencies
                                ForEach(Array(vm.ids), id: \.self) {
                                    Text("\($0)")
                                }
                            }
                        }
                    }

                    Section("Expiration date") {
                        DatePicker("Expiration date", selection: $expirationDate)
                        if canEnableNotifs {
                            Toggle("Enable notifications", isOn: $notifsEnabled)
                        }
                    }

                    Section("Alert type") {
                        Picker("Select Alert Type", selection: $selectedAlertType) {
                            ForEach(AlertTypes.allCases) { alertType in
                                Text(alertType.rawValue).tag(alertType)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())

                        HStack {
                            Text(
                                selectedAlertType == .VolatilityAlert
                                    ? "Price change: " : "Price target: ")
                            TextField("0.0", text: $doubleString)
                                .keyboardType(.decimalPad)
                                .onChange(of: doubleString) { _oldValue, newValue in
                                    if let n = Double(newValue), n > 0 {
                                        doubleValid = true
                                    } else {
                                        doubleValid = false
                                    }
                                }
                            Text(
                                selectedAlertType == .VolatilityAlert
                                    ? "%" : currInfo.currencySymbol)
                        }

                        if !doubleValid {
                            Text("Invalid input").foregroundColor(Color.red)
                        }

                    }

                    Button("Add") {

                        // Print all states
                        debugPrint("id: \(id)")
                        debugPrint("currInfo: \(currInfo)")
                        debugPrint("expirationDate: \(expirationDate)")
                        debugPrint("selectedAlertType: \(selectedAlertType)")
                        Task {
                            state = .sent
                            var res: Bool
                            switch selectedAlertType {
                            case .VolatilityAlert:
                                res = await vm.addVolatilityAlert(
                                    expiration: expirationDate,
                                    volatilityThreshold: Double(doubleString)!, cryptoId: id,
                                    curr: currInfo, notification: notifsEnabled)
                            case .PriceTargetAlert:
                                res = await vm.addPriceTargetAlert(
                                    expiration: expirationDate, targetPrice: Double(doubleString)!,
                                    cryptoId: id, currency: currInfo, notification: notifsEnabled)
                            }
                            state = res ? .succcess : .failure
                            showAlert(
                                message: state == .failure
                                    ? "Could not add alert" : "Alert added successfully")
                        }

                    }
                    .disabled(id.isEmpty || !doubleValid)
                }
                if state == .sent {
                    ProgressView()
                }

            }.navigationTitle("Add alert")
                .alert(alertMessage, isPresented: $showingAlert) {
                    Button("OK", role: .cancel) {
                        state = .notSent
                    }
                }
                .onAppear {
                    Task {
                        canEnableNotifs = await NotificationsService.instance.notificationsEnabled()
                    }
                }
        }
    }
}

#Preview {
    AddAlertView(vm: AlertsViewModel())
}
