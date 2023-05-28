/*
Teaches Measurement and units with precise conversions and formatting.
Covers speed/pace, temperature, length, and a custom unit via Dimension.
Shows arithmetic with Measurement and localized formatting.
Runs fully offline in a Playground.
*/
import Foundation

let mf: MeasurementFormatter = {
    let f = MeasurementFormatter()
    f.unitOptions = .providedUnit
    f.unitStyle = .medium
    f.locale = Locale(identifier: "en_US_POSIX")
    return f
}()

let distance = Measurement(value: 10, unit: UnitLength.kilometers)
let duration: TimeInterval = 45 * 60
let speed = distance.converted(to: .meters).value / duration
let runSpeed = Measurement(value: speed, unit: UnitSpeed.metersPerSecond)

func paceString(for speed: Measurement<UnitSpeed>) -> String {
    let metersPerSecond = speed.converted(to: .metersPerSecond).value
    let secondsPerKm = 1000.0 / metersPerSecond
    let minutes = Int(secondsPerKm) / 60
    let seconds = Int(secondsPerKm) % 60
    return String(format: "%d:%02d per km", minutes, seconds)
}

print("distance:", mf.string(from: distance))
print("avg speed:", mf.string(from: runSpeed.converted(to: .kilometersPerHour)))
print("pace:", paceString(for: runSpeed))

let tempC = Measurement(value: 22.4, unit: UnitTemperature.celsius)
let tempF = tempC.converted(to: .fahrenheit)
let tempK = tempC.converted(to: .kelvin)
print("temp C:", mf.string(from: tempC))
print("temp F:", mf.string(from: tempF))
print("temp K:", mf.string(from: tempK))

let height = Measurement(value: 180, unit: UnitLength.centimeters)
let heightFeet = height.converted(to: .feet)
print("height:", mf.string(from: height))
print("height ft:", mf.string(from: heightFeet))

let bag1 = Measurement(value: 1.5, unit: UnitMass.kilograms)
let bag2 = Measurement(value: 2.25, unit: UnitMass.kilograms)
let totalMass = bag1 + bag2
print("total mass:", mf.string(from: totalMass))

class UnitCoffeeCup: Dimension {
    static let cups = UnitCoffeeCup(symbol: "cup", converter: UnitConverterLinear(coefficient: 0.24))
    
    override class func baseUnit() -> Self {
        return self.init(symbol: "L", converter: UnitConverterLinear(coefficient: 1))
    }
    
    // Provide the designated initializer and required coder initializer.
    required override init(symbol: String, converter: UnitConverter) {
        super.init(symbol: symbol, converter: converter)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

let morningCoffee = Measurement(value: 3, unit: UnitCoffeeCup.cups)
let liters = morningCoffee.converted(to: UnitCoffeeCup(symbol: "L", converter: UnitConverterLinear(coefficient: 1)))
print("coffee:", "\(morningCoffee.value) \(morningCoffee.unit.symbol)")
print("coffee liters:", String(format: "%.2f L", liters.value))

let carSpeed = Measurement(value: 27.78, unit: UnitSpeed.metersPerSecond)
print("car speed mph:", mf.string(from: carSpeed.converted(to: .milesPerHour)))

let climb = Measurement(value: 850, unit: UnitLength.meters)
let climbPerHour = Measurement(value: climb.converted(to: .meters).value / 2.0, unit: UnitLength.meters)
print("climb total:", mf.string(from: climb))
print("climb per hour meters:", String(format: "%.0f m/h", climbPerHour.value))

let fuelLiters = Measurement(value: 50, unit: UnitVolume.liters)
let km = Measurement(value: 650, unit: UnitLength.kilometers)
let lPer100km = Measurement(value: fuelLiters.converted(to: .liters).value / (km.converted(to: .kilometers).value / 100.0), unit: UnitVolume.liters)
print("consumption L/100km:", String(format: "%.1f", lPer100km.value))

let sprint = Measurement(value: 200, unit: UnitLength.meters)
let sprintTime: TimeInterval = 24.3
let sprintSpeed = Measurement(value: sprint.converted(to: .meters).value / sprintTime, unit: UnitSpeed.metersPerSecond)
print("sprint speed km/h:", mf.string(from: sprintSpeed.converted(to: .kilometersPerHour)))
