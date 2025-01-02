enum AlertTypes: String, CaseIterable, Identifiable {
    case VolatilityAlert
    case PriceTargetAlert
    
    var id: String { self.rawValue }
}