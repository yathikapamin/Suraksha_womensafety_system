class DangerZone {
  final String area;
  final double latitude;
  final double longitude;
  final int totalCrimes;
  final String riskLevel;

  const DangerZone({
    required this.area,
    required this.latitude,
    required this.longitude,
    required this.totalCrimes,
    required this.riskLevel,
  });
}

class DangerZonesData {
  static const List<DangerZone> bangaloreZones = [
    DangerZone(area: "Whitefield", latitude: 12.9963995, longitude: 77.7614229, totalCrimes: 305, riskLevel: "High"),
    DangerZone(area: "Electronic City", latitude: 12.8487599, longitude: 77.648253, totalCrimes: 343, riskLevel: "High"),
    DangerZone(area: "Marathahalli", latitude: 12.9552572, longitude: 77.6984163, totalCrimes: 268, riskLevel: "Medium"),
    DangerZone(area: "Bellandur", latitude: 12.9371445, longitude: 77.6720227, totalCrimes: 284, riskLevel: "Medium"),
    DangerZone(area: "ORR", latitude: 13.0354024, longitude: 77.5413987, totalCrimes: 326, riskLevel: "High"),
    DangerZone(area: "KR Puram", latitude: 13.007516, longitude: 77.695935, totalCrimes: 236, riskLevel: "Medium"),
    DangerZone(area: "HSR Layout", latitude: 12.9116225, longitude: 77.6388622, totalCrimes: 252, riskLevel: "Medium"),
    DangerZone(area: "BTM Layout", latitude: 12.9140008, longitude: 77.6102821, totalCrimes: 294, riskLevel: "Medium"),
    DangerZone(area: "Indiranagar", latitude: 12.9732913, longitude: 77.6404672, totalCrimes: 247, riskLevel: "Medium"),
    DangerZone(area: "Koramangala", latitude: 12.9357366, longitude: 77.624081, totalCrimes: 268, riskLevel: "Medium"),
    DangerZone(area: "Jayanagar", latitude: 12.9292731, longitude: 77.5824229, totalCrimes: 188, riskLevel: "Low"),
    DangerZone(area: "JP Nagar", latitude: 12.9096941, longitude: 77.5866067, totalCrimes: 204, riskLevel: "Medium"),
    DangerZone(area: "Banashankari", latitude: 12.9278196, longitude: 77.556621, totalCrimes: 220, riskLevel: "Medium"),
    DangerZone(area: "Basavanagudi", latitude: 12.9417261, longitude: 77.5755021, totalCrimes: 172, riskLevel: "Low"),
    DangerZone(area: "Malleshwaram", latitude: 13.0027353, longitude: 77.5703253, totalCrimes: 186, riskLevel: "Low"),
    DangerZone(area: "Rajajinagar", latitude: 13.0005232, longitude: 77.5496166, totalCrimes: 201, riskLevel: "Medium"),
    DangerZone(area: "Yelahanka", latitude: 13.1006982, longitude: 77.5963454, totalCrimes: 215, riskLevel: "Medium"),
    DangerZone(area: "Hebbal", latitude: 13.0382184, longitude: 77.5919, totalCrimes: 184, riskLevel: "Low"),
    DangerZone(area: "RT Nagar", latitude: 13.0227204, longitude: 77.595715, totalCrimes: 186, riskLevel: "Low"),
    DangerZone(area: "Vijayanagar", latitude: 12.9709537, longitude: 77.5373851, totalCrimes: 204, riskLevel: "Medium"),
    DangerZone(area: "Majestic", latitude: 12.9779079, longitude: 77.5723936, totalCrimes: 370, riskLevel: "High"),
    DangerZone(area: "Shivajinagar", latitude: 12.9855286, longitude: 77.6054496, totalCrimes: 348, riskLevel: "High"),
    DangerZone(area: "City Market", latitude: 12.965718, longitude: 77.5762705, totalCrimes: 332, riskLevel: "High"),
    DangerZone(area: "KR Market", latitude: 12.9645, longitude: 77.5761889, totalCrimes: 319, riskLevel: "High"),
    DangerZone(area: "Yeshwanthpur", latitude: 13.0176937, longitude: 77.5555009, totalCrimes: 284, riskLevel: "Medium"),
    DangerZone(area: "Baiyappanahalli", latitude: 12.9907136, longitude: 77.6523733, totalCrimes: 268, riskLevel: "Medium"),
    DangerZone(area: "Sarjapur", latitude: 12.9116225, longitude: 77.6388622, totalCrimes: 247, riskLevel: "Medium"),
    DangerZone(area: "Devanahalli", latitude: 13.2483502, longitude: 77.7134377, totalCrimes: 173, riskLevel: "Low"),
    DangerZone(area: "Kengeri", latitude: 12.9176571, longitude: 77.4837568, totalCrimes: 194, riskLevel: "Low"),
    DangerZone(area: "Nagarbhavi", latitude: 12.9512353, longitude: 77.519054, totalCrimes: 215, riskLevel: "Medium"),
    DangerZone(area: "Hennur", latitude: 13.037077, longitude: 77.6413572, totalCrimes: 231, riskLevel: "Medium"),
    DangerZone(area: "Thanisandra", latitude: 13.0522499, longitude: 77.6316152, totalCrimes: 247, riskLevel: "Medium"),
    DangerZone(area: "Horamavu", latitude: 13.0273312, longitude: 77.6601508, totalCrimes: 217, riskLevel: "Medium"),
    DangerZone(area: "Kadugodi", latitude: 12.9957428, longitude: 77.7579489, totalCrimes: 234, riskLevel: "Medium"),
    DangerZone(area: "Domlur", latitude: 12.9624669, longitude: 77.6381958, totalCrimes: 230, riskLevel: "Medium"),
    DangerZone(area: "Ulsoor", latitude: 12.9778793, longitude: 77.6246697, totalCrimes: 214, riskLevel: "Medium"),
    DangerZone(area: "Frazer Town", latitude: 12.9975851, longitude: 77.6136744, totalCrimes: 246, riskLevel: "Medium"),
    DangerZone(area: "Cox Town", latitude: 12.9934859, longitude: 77.6251081, totalCrimes: 230, riskLevel: "Medium"),
    DangerZone(area: "Cooke Town", latitude: 13.0021998, longitude: 77.6251814, totalCrimes: 212, riskLevel: "Medium"),
    DangerZone(area: "Sadashivanagar", latitude: 13.0110193, longitude: 77.5808641, totalCrimes: 156, riskLevel: "Low"),
    DangerZone(area: "Sanjay Nagar", latitude: 12.9578658, longitude: 77.6958748, totalCrimes: 188, riskLevel: "Low"),
    DangerZone(area: "Dollars Colony", latitude: 13.0413668, longitude: 77.5678155, totalCrimes: 140, riskLevel: "Low"),
    DangerZone(area: "Basaveshwar Nagar", latitude: 12.9728678, longitude: 77.6094161, totalCrimes: 214, riskLevel: "Medium"),
    DangerZone(area: "Chandra Layout", latitude: 12.955333, longitude: 77.5238903, totalCrimes: 230, riskLevel: "Medium"),
    DangerZone(area: "Magadi Road", latitude: 12.9756527, longitude: 77.5553548, totalCrimes: 252, riskLevel: "Medium"),
    DangerZone(area: "Peenya", latitude: 13.0330515, longitude: 77.5332233, totalCrimes: 289, riskLevel: "Medium"),
    DangerZone(area: "Jalahalli", latitude: 13.0394104, longitude: 77.5197351, totalCrimes: 204, riskLevel: "Medium"),
    DangerZone(area: "Vidyaranyapura", latitude: 13.0766407, longitude: 77.5577315, totalCrimes: 188, riskLevel: "Low"),
    DangerZone(area: "Sahakar Nagar", latitude: 13.069641, longitude: 77.5857251, totalCrimes: 172, riskLevel: "Low"),
    DangerZone(area: "Banaswadi", latitude: 13.0141618, longitude: 77.6518539, totalCrimes: 230, riskLevel: "Medium"),
    DangerZone(area: "Ramamurthy Nagar", latitude: 13.0120218, longitude: 77.6777817, totalCrimes: 246, riskLevel: "Medium"),
    DangerZone(area: "CV Raman Nagar", latitude: 12.9850987, longitude: 77.6631174, totalCrimes: 212, riskLevel: "Medium"),
    DangerZone(area: "Brookefield", latitude: 12.9652094, longitude: 77.717936, totalCrimes: 252, riskLevel: "Medium"),
    DangerZone(area: "Kundalahalli", latitude: 12.977594, longitude: 77.7155586, totalCrimes: 236, riskLevel: "Medium"),
    DangerZone(area: "Varthur", latitude: 12.9406508, longitude: 77.746988, totalCrimes: 268, riskLevel: "Medium"),
    DangerZone(area: "Gunjur", latitude: 12.9209772, longitude: 77.7361016, totalCrimes: 230, riskLevel: "Medium"),
    DangerZone(area: "Bommanahalli", latitude: 12.9034582, longitude: 77.6230028, totalCrimes: 289, riskLevel: "Medium"),
    DangerZone(area: "Hongasandra", latitude: 12.8986261, longitude: 77.6286732, totalCrimes: 252, riskLevel: "Medium"),
    DangerZone(area: "Begur", latitude: 12.8633887, longitude: 77.6130112, totalCrimes: 236, riskLevel: "Medium"),
    DangerZone(area: "Hulimavu", latitude: 12.8773486, longitude: 77.6028031, totalCrimes: 230, riskLevel: "Medium"),
    DangerZone(area: "Arekere", latitude: 12.8872086, longitude: 77.5960493, totalCrimes: 214, riskLevel: "Medium"),
    DangerZone(area: "Bannerghatta Road", latitude: 12.9396275, longitude: 77.6021696, totalCrimes: 268, riskLevel: "Medium"),
    DangerZone(area: "Wilson Garden", latitude: 12.9489339, longitude: 77.5968273, totalCrimes: 246, riskLevel: "Medium"),
    DangerZone(area: "Richmond Town", latitude: 12.963555, longitude: 77.6015856, totalCrimes: 230, riskLevel: "Medium")
  ];
}
