//
//  MicroNutrients.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 1/14/26.
//

import Foundation
import SwiftData

// MARK: - Comprehensive Micronutrients Model

/// Complete micronutrient profile for comprehensive nutrition tracking
/// Based on Cronometer's extensive nutrient database
struct MicroNutrients: Codable, Hashable {
    // MARK: - Vitamins
    
    /// Vitamin A (mcg RAE)
    var vitaminA: Double?
    
    /// Vitamin C (mg)
    var vitaminC: Double?
    
    /// Vitamin D (mcg)
    var vitaminD: Double?
    
    /// Vitamin E (mg)
    var vitaminE: Double?
    
    /// Vitamin K (mcg)
    var vitaminK: Double?
    
    // MARK: - B Vitamins
    
    /// Thiamin / B1 (mg)
    var vitaminB1: Double?
    
    /// Riboflavin / B2 (mg)
    var vitaminB2: Double?
    
    /// Niacin / B3 (mg)
    var vitaminB3: Double?
    
    /// Pantothenic Acid / B5 (mg)
    var vitaminB5: Double?
    
    /// Pyridoxine / B6 (mg)
    var vitaminB6: Double?
    
    /// Biotin / B7 (mcg)
    var vitaminB7: Double?
    
    /// Folate / B9 (mcg DFE)
    var vitaminB9: Double?
    
    /// Cobalamin / B12 (mcg)
    var vitaminB12: Double?
    
    // MARK: - Minerals
    
    /// Calcium (mg)
    var calcium: Double?
    
    /// Iron (mg)
    var iron: Double?
    
    /// Magnesium (mg)
    var magnesium: Double?
    
    /// Phosphorus (mg)
    var phosphorus: Double?
    
    /// Potassium (mg)
    var potassium: Double?
    
    /// Sodium (mg)
    var sodium: Double?
    
    /// Zinc (mg)
    var zinc: Double?
    
    /// Copper (mg)
    var copper: Double?
    
    /// Manganese (mg)
    var manganese: Double?
    
    /// Selenium (mcg)
    var selenium: Double?
    
    /// Iodine (mcg)
    var iodine: Double?
    
    /// Chromium (mcg)
    var chromium: Double?
    
    /// Molybdenum (mcg)
    var molybdenum: Double?
    
    // MARK: - Fatty Acids
    
    /// Saturated Fat (g)
    var saturatedFat: Double?
    
    /// Monounsaturated Fat (g)
    var monounsaturatedFat: Double?
    
    /// Polyunsaturated Fat (g)
    var polyunsaturatedFat: Double?
    
    /// Trans Fat (g)
    var transFat: Double?
    
    /// Omega-3 (g)
    var omega3: Double?
    
    /// Omega-6 (g)
    var omega6: Double?
    
    /// EPA (mg)
    var epa: Double?
    
    /// DHA (mg)
    var dha: Double?
    
    // MARK: - Other
    
    /// Cholesterol (mg)
    var cholesterol: Double?
    
    /// Choline (mg)
    var choline: Double?
    
    // MARK: - Initialization
    
    init(
        vitaminA: Double? = nil,
        vitaminC: Double? = nil,
        vitaminD: Double? = nil,
        vitaminE: Double? = nil,
        vitaminK: Double? = nil,
        vitaminB1: Double? = nil,
        vitaminB2: Double? = nil,
        vitaminB3: Double? = nil,
        vitaminB5: Double? = nil,
        vitaminB6: Double? = nil,
        vitaminB7: Double? = nil,
        vitaminB9: Double? = nil,
        vitaminB12: Double? = nil,
        calcium: Double? = nil,
        iron: Double? = nil,
        magnesium: Double? = nil,
        phosphorus: Double? = nil,
        potassium: Double? = nil,
        sodium: Double? = nil,
        zinc: Double? = nil,
        copper: Double? = nil,
        manganese: Double? = nil,
        selenium: Double? = nil,
        iodine: Double? = nil,
        chromium: Double? = nil,
        molybdenum: Double? = nil,
        saturatedFat: Double? = nil,
        monounsaturatedFat: Double? = nil,
        polyunsaturatedFat: Double? = nil,
        transFat: Double? = nil,
        omega3: Double? = nil,
        omega6: Double? = nil,
        epa: Double? = nil,
        dha: Double? = nil,
        cholesterol: Double? = nil,
        choline: Double? = nil
    ) {
        self.vitaminA = vitaminA
        self.vitaminC = vitaminC
        self.vitaminD = vitaminD
        self.vitaminE = vitaminE
        self.vitaminK = vitaminK
        self.vitaminB1 = vitaminB1
        self.vitaminB2 = vitaminB2
        self.vitaminB3 = vitaminB3
        self.vitaminB5 = vitaminB5
        self.vitaminB6 = vitaminB6
        self.vitaminB7 = vitaminB7
        self.vitaminB9 = vitaminB9
        self.vitaminB12 = vitaminB12
        self.calcium = calcium
        self.iron = iron
        self.magnesium = magnesium
        self.phosphorus = phosphorus
        self.potassium = potassium
        self.sodium = sodium
        self.zinc = zinc
        self.copper = copper
        self.manganese = manganese
        self.selenium = selenium
        self.iodine = iodine
        self.chromium = chromium
        self.molybdenum = molybdenum
        self.saturatedFat = saturatedFat
        self.monounsaturatedFat = monounsaturatedFat
        self.polyunsaturatedFat = polyunsaturatedFat
        self.transFat = transFat
        self.omega3 = omega3
        self.omega6 = omega6
        self.epa = epa
        self.dha = dha
        self.cholesterol = cholesterol
        self.choline = choline
    }
    
    // MARK: - Arithmetic Operations
    
    /// Add two micronutrient profiles together
    static func + (lhs: MicroNutrients, rhs: MicroNutrients) -> MicroNutrients {
        MicroNutrients(
            vitaminA: addOptionals(lhs.vitaminA, rhs.vitaminA),
            vitaminC: addOptionals(lhs.vitaminC, rhs.vitaminC),
            vitaminD: addOptionals(lhs.vitaminD, rhs.vitaminD),
            vitaminE: addOptionals(lhs.vitaminE, rhs.vitaminE),
            vitaminK: addOptionals(lhs.vitaminK, rhs.vitaminK),
            vitaminB1: addOptionals(lhs.vitaminB1, rhs.vitaminB1),
            vitaminB2: addOptionals(lhs.vitaminB2, rhs.vitaminB2),
            vitaminB3: addOptionals(lhs.vitaminB3, rhs.vitaminB3),
            vitaminB5: addOptionals(lhs.vitaminB5, rhs.vitaminB5),
            vitaminB6: addOptionals(lhs.vitaminB6, rhs.vitaminB6),
            vitaminB7: addOptionals(lhs.vitaminB7, rhs.vitaminB7),
            vitaminB9: addOptionals(lhs.vitaminB9, rhs.vitaminB9),
            vitaminB12: addOptionals(lhs.vitaminB12, rhs.vitaminB12),
            calcium: addOptionals(lhs.calcium, rhs.calcium),
            iron: addOptionals(lhs.iron, rhs.iron),
            magnesium: addOptionals(lhs.magnesium, rhs.magnesium),
            phosphorus: addOptionals(lhs.phosphorus, rhs.phosphorus),
            potassium: addOptionals(lhs.potassium, rhs.potassium),
            sodium: addOptionals(lhs.sodium, rhs.sodium),
            zinc: addOptionals(lhs.zinc, rhs.zinc),
            copper: addOptionals(lhs.copper, rhs.copper),
            manganese: addOptionals(lhs.manganese, rhs.manganese),
            selenium: addOptionals(lhs.selenium, rhs.selenium),
            iodine: addOptionals(lhs.iodine, rhs.iodine),
            chromium: addOptionals(lhs.chromium, rhs.chromium),
            molybdenum: addOptionals(lhs.molybdenum, rhs.molybdenum),
            saturatedFat: addOptionals(lhs.saturatedFat, rhs.saturatedFat),
            monounsaturatedFat: addOptionals(lhs.monounsaturatedFat, rhs.monounsaturatedFat),
            polyunsaturatedFat: addOptionals(lhs.polyunsaturatedFat, rhs.polyunsaturatedFat),
            transFat: addOptionals(lhs.transFat, rhs.transFat),
            omega3: addOptionals(lhs.omega3, rhs.omega3),
            omega6: addOptionals(lhs.omega6, rhs.omega6),
            epa: addOptionals(lhs.epa, rhs.epa),
            dha: addOptionals(lhs.dha, rhs.dha),
            cholesterol: addOptionals(lhs.cholesterol, rhs.cholesterol),
            choline: addOptionals(lhs.choline, rhs.choline)
        )
    }
    
    /// Scale micronutrients by a multiplier
    func scaled(by multiplier: Double) -> MicroNutrients {
        MicroNutrients(
            vitaminA: vitaminA.map { $0 * multiplier },
            vitaminC: vitaminC.map { $0 * multiplier },
            vitaminD: vitaminD.map { $0 * multiplier },
            vitaminE: vitaminE.map { $0 * multiplier },
            vitaminK: vitaminK.map { $0 * multiplier },
            vitaminB1: vitaminB1.map { $0 * multiplier },
            vitaminB2: vitaminB2.map { $0 * multiplier },
            vitaminB3: vitaminB3.map { $0 * multiplier },
            vitaminB5: vitaminB5.map { $0 * multiplier },
            vitaminB6: vitaminB6.map { $0 * multiplier },
            vitaminB7: vitaminB7.map { $0 * multiplier },
            vitaminB9: vitaminB9.map { $0 * multiplier },
            vitaminB12: vitaminB12.map { $0 * multiplier },
            calcium: calcium.map { $0 * multiplier },
            iron: iron.map { $0 * multiplier },
            magnesium: magnesium.map { $0 * multiplier },
            phosphorus: phosphorus.map { $0 * multiplier },
            potassium: potassium.map { $0 * multiplier },
            sodium: sodium.map { $0 * multiplier },
            zinc: zinc.map { $0 * multiplier },
            copper: copper.map { $0 * multiplier },
            manganese: manganese.map { $0 * multiplier },
            selenium: selenium.map { $0 * multiplier },
            iodine: iodine.map { $0 * multiplier },
            chromium: chromium.map { $0 * multiplier },
            molybdenum: molybdenum.map { $0 * multiplier },
            saturatedFat: saturatedFat.map { $0 * multiplier },
            monounsaturatedFat: monounsaturatedFat.map { $0 * multiplier },
            polyunsaturatedFat: polyunsaturatedFat.map { $0 * multiplier },
            transFat: transFat.map { $0 * multiplier },
            omega3: omega3.map { $0 * multiplier },
            omega6: omega6.map { $0 * multiplier },
            epa: epa.map { $0 * multiplier },
            dha: dha.map { $0 * multiplier },
            cholesterol: cholesterol.map { $0 * multiplier },
            choline: choline.map { $0 * multiplier }
        )
    }
    
    private static func addOptionals(_ a: Double?, _ b: Double?) -> Double? {
        switch (a, b) {
        case (.some(let aVal), .some(let bVal)):
            return aVal + bVal
        case (.some(let val), .none), (.none, .some(let val)):
            return val
        case (.none, .none):
            return nil
        }
    }
}

// MARK: - RDA (Recommended Daily Allowance) Targets

/// Recommended daily allowances based on age and sex
/// Values from NIH/USDA dietary guidelines
struct NutrientRDA {
    let nutrientName: String
    let unit: String
    let target: Double
    let upperLimit: Double?
    
    // MARK: - Standard Adult RDAs (19-50 years)
    
    static let adultMale: [String: NutrientRDA] = [
        "vitaminA": NutrientRDA(nutrientName: "Vitamin A", unit: "mcg", target: 900, upperLimit: 3000),
        "vitaminC": NutrientRDA(nutrientName: "Vitamin C", unit: "mg", target: 90, upperLimit: 2000),
        "vitaminD": NutrientRDA(nutrientName: "Vitamin D", unit: "mcg", target: 15, upperLimit: 100),
        "vitaminE": NutrientRDA(nutrientName: "Vitamin E", unit: "mg", target: 15, upperLimit: 1000),
        "vitaminK": NutrientRDA(nutrientName: "Vitamin K", unit: "mcg", target: 120, upperLimit: nil),
        "vitaminB1": NutrientRDA(nutrientName: "Thiamin (B1)", unit: "mg", target: 1.2, upperLimit: nil),
        "vitaminB2": NutrientRDA(nutrientName: "Riboflavin (B2)", unit: "mg", target: 1.3, upperLimit: nil),
        "vitaminB3": NutrientRDA(nutrientName: "Niacin (B3)", unit: "mg", target: 16, upperLimit: 35),
        "vitaminB5": NutrientRDA(nutrientName: "Pantothenic Acid (B5)", unit: "mg", target: 5, upperLimit: nil),
        "vitaminB6": NutrientRDA(nutrientName: "Pyridoxine (B6)", unit: "mg", target: 1.3, upperLimit: 100),
        "vitaminB7": NutrientRDA(nutrientName: "Biotin (B7)", unit: "mcg", target: 30, upperLimit: nil),
        "vitaminB9": NutrientRDA(nutrientName: "Folate (B9)", unit: "mcg", target: 400, upperLimit: 1000),
        "vitaminB12": NutrientRDA(nutrientName: "Cobalamin (B12)", unit: "mcg", target: 2.4, upperLimit: nil),
        "calcium": NutrientRDA(nutrientName: "Calcium", unit: "mg", target: 1000, upperLimit: 2500),
        "iron": NutrientRDA(nutrientName: "Iron", unit: "mg", target: 8, upperLimit: 45),
        "magnesium": NutrientRDA(nutrientName: "Magnesium", unit: "mg", target: 400, upperLimit: 350),
        "phosphorus": NutrientRDA(nutrientName: "Phosphorus", unit: "mg", target: 700, upperLimit: 4000),
        "potassium": NutrientRDA(nutrientName: "Potassium", unit: "mg", target: 3400, upperLimit: nil),
        "sodium": NutrientRDA(nutrientName: "Sodium", unit: "mg", target: 1500, upperLimit: 2300),
        "zinc": NutrientRDA(nutrientName: "Zinc", unit: "mg", target: 11, upperLimit: 40),
        "copper": NutrientRDA(nutrientName: "Copper", unit: "mg", target: 0.9, upperLimit: 10),
        "manganese": NutrientRDA(nutrientName: "Manganese", unit: "mg", target: 2.3, upperLimit: 11),
        "selenium": NutrientRDA(nutrientName: "Selenium", unit: "mcg", target: 55, upperLimit: 400),
        "iodine": NutrientRDA(nutrientName: "Iodine", unit: "mcg", target: 150, upperLimit: 1100),
        "chromium": NutrientRDA(nutrientName: "Chromium", unit: "mcg", target: 35, upperLimit: nil),
        "molybdenum": NutrientRDA(nutrientName: "Molybdenum", unit: "mcg", target: 45, upperLimit: 2000),
        "choline": NutrientRDA(nutrientName: "Choline", unit: "mg", target: 550, upperLimit: 3500),
        "omega3": NutrientRDA(nutrientName: "Omega-3", unit: "g", target: 1.6, upperLimit: nil),
    ]
    
    static let adultFemale: [String: NutrientRDA] = [
        "vitaminA": NutrientRDA(nutrientName: "Vitamin A", unit: "mcg", target: 700, upperLimit: 3000),
        "vitaminC": NutrientRDA(nutrientName: "Vitamin C", unit: "mg", target: 75, upperLimit: 2000),
        "vitaminD": NutrientRDA(nutrientName: "Vitamin D", unit: "mcg", target: 15, upperLimit: 100),
        "vitaminE": NutrientRDA(nutrientName: "Vitamin E", unit: "mg", target: 15, upperLimit: 1000),
        "vitaminK": NutrientRDA(nutrientName: "Vitamin K", unit: "mcg", target: 90, upperLimit: nil),
        "vitaminB1": NutrientRDA(nutrientName: "Thiamin (B1)", unit: "mg", target: 1.1, upperLimit: nil),
        "vitaminB2": NutrientRDA(nutrientName: "Riboflavin (B2)", unit: "mg", target: 1.1, upperLimit: nil),
        "vitaminB3": NutrientRDA(nutrientName: "Niacin (B3)", unit: "mg", target: 14, upperLimit: 35),
        "vitaminB5": NutrientRDA(nutrientName: "Pantothenic Acid (B5)", unit: "mg", target: 5, upperLimit: nil),
        "vitaminB6": NutrientRDA(nutrientName: "Pyridoxine (B6)", unit: "mg", target: 1.3, upperLimit: 100),
        "vitaminB7": NutrientRDA(nutrientName: "Biotin (B7)", unit: "mcg", target: 30, upperLimit: nil),
        "vitaminB9": NutrientRDA(nutrientName: "Folate (B9)", unit: "mcg", target: 400, upperLimit: 1000),
        "vitaminB12": NutrientRDA(nutrientName: "Cobalamin (B12)", unit: "mcg", target: 2.4, upperLimit: nil),
        "calcium": NutrientRDA(nutrientName: "Calcium", unit: "mg", target: 1000, upperLimit: 2500),
        "iron": NutrientRDA(nutrientName: "Iron", unit: "mg", target: 18, upperLimit: 45),
        "magnesium": NutrientRDA(nutrientName: "Magnesium", unit: "mg", target: 310, upperLimit: 350),
        "phosphorus": NutrientRDA(nutrientName: "Phosphorus", unit: "mg", target: 700, upperLimit: 4000),
        "potassium": NutrientRDA(nutrientName: "Potassium", unit: "mg", target: 2600, upperLimit: nil),
        "sodium": NutrientRDA(nutrientName: "Sodium", unit: "mg", target: 1500, upperLimit: 2300),
        "zinc": NutrientRDA(nutrientName: "Zinc", unit: "mg", target: 8, upperLimit: 40),
        "copper": NutrientRDA(nutrientName: "Copper", unit: "mg", target: 0.9, upperLimit: 10),
        "manganese": NutrientRDA(nutrientName: "Manganese", unit: "mg", target: 1.8, upperLimit: 11),
        "selenium": NutrientRDA(nutrientName: "Selenium", unit: "mcg", target: 55, upperLimit: 400),
        "iodine": NutrientRDA(nutrientName: "Iodine", unit: "mcg", target: 150, upperLimit: 1100),
        "chromium": NutrientRDA(nutrientName: "Chromium", unit: "mcg", target: 25, upperLimit: nil),
        "molybdenum": NutrientRDA(nutrientName: "Molybdenum", unit: "mcg", target: 45, upperLimit: 2000),
        "choline": NutrientRDA(nutrientName: "Choline", unit: "mg", target: 425, upperLimit: 3500),
        "omega3": NutrientRDA(nutrientName: "Omega-3", unit: "g", target: 1.1, upperLimit: nil),
    ]
}

// MARK: - Nutrient Status

/// Status indicator for nutrient intake vs RDA
enum NutrientStatus {
    case deficient      // < 50% of RDA
    case low            // 50-75% of RDA
    case adequate       // 75-100% of RDA
    case optimal        // 100-150% of RDA
    case high           // 150-200% of RDA
    case excess         // > 200% of RDA or above upper limit
    
    var color: String {
        switch self {
        case .deficient: return "red"
        case .low: return "orange"
        case .adequate: return "yellow"
        case .optimal: return "green"
        case .high: return "blue"
        case .excess: return "purple"
        }
    }
    
    static func calculate(current: Double, target: Double, upperLimit: Double?) -> NutrientStatus {
        let percentage = (current / target) * 100
        
        // Check upper limit first
        if let upper = upperLimit, current > upper {
            return .excess
        }
        
        switch percentage {
        case ..<50:
            return .deficient
        case 50..<75:
            return .low
        case 75..<100:
            return .adequate
        case 100..<150:
            return .optimal
        case 150..<200:
            return .high
        default:
            return .excess
        }
    }
}
