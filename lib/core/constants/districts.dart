// Sri Lanka's 25 districts.
// The English name is stored in Firestore (used later for notification targeting);
// the Sinhala name is only for display.
class District {
  final String en;
  final String si;
  const District(this.en, this.si);
}

const List<District> sriLankaDistricts = [
  District('Ampara', 'අම්පාර'),
  District('Anuradhapura', 'අනුරාධපුර'),
  District('Badulla', 'බදුල්ල'),
  District('Batticaloa', 'මඩකලපුව'),
  District('Colombo', 'කොළඹ'),
  District('Galle', 'ගාල්ල'),
  District('Gampaha', 'ගම්පහ'),
  District('Hambantota', 'හම්බන්තොට'),
  District('Jaffna', 'යාපනය'),
  District('Kalutara', 'කළුතර'),
  District('Kandy', 'මහනුවර'),
  District('Kegalle', 'කෑගල්ල'),
  District('Kilinochchi', 'කිලිනොච්චි'),
  District('Kurunegala', 'කුරුණෑගල'),
  District('Mannar', 'මන්නාරම'),
  District('Matale', 'මාතලේ'),
  District('Matara', 'මාතර'),
  District('Monaragala', 'මොණරාගල'),
  District('Mullaitivu', 'මුලතිව්'),
  District('Nuwara Eliya', 'නුවරඑළිය'),
  District('Polonnaruwa', 'පොලොන්නරුව'),
  District('Puttalam', 'පුත්තලම'),
  District('Ratnapura', 'රත්නපුර'),
  District('Trincomalee', 'ත්‍රිකුණාමලය'),
  District('Vavuniya', 'වවුනියාව'),
];