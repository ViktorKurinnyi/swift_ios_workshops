/*
Teaches safe date math across calendars and time zones.
Builds helpers for start-of-day, next weekday, wall-clock schedules, DST edges.
Uses Europe/Madrid to demonstrate spring-forward and fall-back correctly.
All output formats are ISO-like for clarity.
*/
import Foundation

let tz = TimeZone(identifier: "Europe/Madrid")!
var cal = Calendar(identifier: .gregorian)
cal.timeZone = tz

func iso(_ d: Date) -> String {
    let f = ISO8601DateFormatter()
    f.timeZone = tz
    f.formatOptions = [.withFullDate, .withTime, .withColonSeparatorInTime]
    return f.string(from: d)
}

func startOfDay(_ d: Date) -> Date {
    cal.startOfDay(for: d)
}

func nextWeekday(after d: Date, _ weekday: Int, hour: Int, minute: Int) -> Date {
    var comps = DateComponents()
    comps.weekday = weekday
    comps.hour = hour
    comps.minute = minute
    return cal.nextDate(after: d, matching: comps, matchingPolicy: .nextTime, direction: .forward)!
}

func businessDaysBetween(_ a: Date, _ b: Date) -> Int {
    var c = cal
    c.timeZone = tz
    let start = c.startOfDay(for: min(a, b))
    let end = c.startOfDay(for: max(a, b))
    var d = start
    var n = 0
    while d < end {
        let wd = c.component(.weekday, from: d)
        if wd != 1 && wd != 7 { n += 1 }
        d = c.date(byAdding: .day, value: 1, to: d)!
    }
    return (a <= b) ? n : -n
}

func endOfMonth(for d: Date) -> Date {
    let s = startOfDay(d)
    var comps = DateComponents()
    comps.month = 1
    comps.day = -1
    return cal.date(byAdding: comps, to: cal.date(from: cal.dateComponents([.year, .month], from: s))!)!
}

func safeAddMonths(_ d: Date, _ months: Int) -> Date {
    let parts = cal.dateComponents([.year, .month, .day], from: d)
    var target = DateComponents()
    target.year = parts.year
    target.month = (parts.month ?? 1) + months
    target.day = min(parts.day ?? 1, 28)
    let anchor = cal.date(from: target)!
    let eom = endOfMonth(for: anchor)
    let desiredDay = parts.day ?? 1
    if desiredDay > 28 {
        let daysInTarget = cal.component(.day, from: eom)
        let finalDay = min(desiredDay, daysInTarget)
        var final = cal.dateComponents([.year, .month], from: eom)
        final.day = finalDay
        final.hour = cal.component(.hour, from: d)
        final.minute = cal.component(.minute, from: d)
        final.second = cal.component(.second, from: d)
        return cal.date(from: final)!
    } else {
        var comps = cal.dateComponents([.year, .month, .day, .hour, .minute, .second], from: d)
        comps.month! += months
        return cal.date(from: comps)!
    }
}

func dailyWallClockOccurrences(starting start: Date, hour: Int, minute: Int, count: Int) -> [Date] {
    var out: [Date] = []
    var cursor = start
    for _ in 0..<count {
        var c = cal.dateComponents([.year, .month, .day], from: cursor)
        c.hour = hour
        c.minute = minute
        if let t = cal.date(from: c) {
            out.append(t)
        }
        cursor = cal.date(byAdding: .day, value: 1, to: cursor)!
    }
    return out
}

let now = Date()
print("now:", iso(now))
print("start of today:", iso(startOfDay(now)))

let upcomingMonday = nextWeekday(after: now, 2, hour: 9, minute: 30)
print("next Monday 09:30:", iso(upcomingMonday))

let a = cal.date(from: DateComponents(year: 2025, month: 1, day: 31, hour: 12, minute: 0))!
let plus1 = safeAddMonths(a, 1)
let plus2 = safeAddMonths(a, 2)
print("Jan 31 +1 month:", iso(plus1))
print("Jan 31 +2 months:", iso(plus2))

let madridSpring = cal.date(from: DateComponents(year: 2025, month: 3, day: 30, hour: 1, minute: 30))!
let addHourSpring = cal.date(byAdding: .hour, value: 1, to: madridSpring)!
print("DST spring start base:", iso(madridSpring))
print("DST spring +1h:", iso(addHourSpring))

let madridFall = cal.date(from: DateComponents(year: 2025, month: 10, day: 26, hour: 1, minute: 30))!
let addHourFall = cal.date(byAdding: .hour, value: 1, to: madridFall)!
print("DST fall base:", iso(madridFall))
print("DST fall +1h:", iso(addHourFall))

let morning9 = dailyWallClockOccurrences(starting: cal.date(from: DateComponents(year: 2025, month: 10, day: 24))!, hour: 9, minute: 0, count: 5)
print("wall 09:00 across DST end:")
for d in morning9 { print(" -", iso(d)) }

let d1 = cal.date(from: DateComponents(year: 2025, month: 8, day: 1))!
let d2 = cal.date(from: DateComponents(year: 2025, month: 8, day: 31))!
print("business days in Aug 2025:", businessDaysBetween(d1, d2))

let meeting = cal.date(from: DateComponents(year: 2025, month: 9, day: 1, hour: 17, minute: 0))!
print("meeting local:", iso(meeting))
let ny = TimeZone(identifier: "America/New_York")!
var calNY = Calendar(identifier: .gregorian)
calNY.timeZone = ny
let f = ISO8601DateFormatter()
f.timeZone = ny
f.formatOptions = [.withFullDate, .withTime, .withColonSeparatorInTime]
print("meeting in New York:", f.string(from: meeting))
