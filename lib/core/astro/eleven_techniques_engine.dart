// Paste this - Build #19 Engine
class ElevenTechniquesEngine {
  static const orbs = [0,60,90,120,180,210,240,270];
  static List<AstroEvent> generateAstroEvents({
    required DateTime from, required DateTime to,
    required int selectedHouse, required Map natalChart, required Map dashaData,
  }) {
    List<AstroEvent> events = [];
    // MD = 14 types, Others = 3 types (07, -07H, -07L) as you said!
    // Calendar Months: 01-Oct to 31-Dec
    // TODO: Connect to your sweph wrapper
    return events;
  }
}
class AstroEvent {
  DateTime date; String code; String technique; int house;
  AstroEvent({required this.date, required this.code, required this.technique, required this.house});
  String get display => "${date.day.toString().padLeft(2,'0')}-${date.month.toString().padLeft(2,'0')}-${date.year}  $code";
}
