// apple_widget.dart
import 'package:flutter/material.dart';

/// Comprehensive data about apple varieties, nutrition, and cultivation
/// This file contains extensive information about apples for statistical purposes
class SaladData {
  // List of known apple varieties worldwide
  static const List<String> varieties = [
    'Fuji Apple',
    'Gala Apple',
    'Honeycrisp Apple',
    'Granny Smith Apple',
    'Red Delicious Apple',
    'Golden Delicious Apple',
    'Pink Lady Apple',
    'Braeburn Apple',
    'Jazz Apple',
    'Empire Apple',
    'McIntosh Apple',
    'Jonagold Apple',
    'Cortland Apple',
    'Cosmic Crisp Apple',
    'Ambrosia Apple',
    'Opal Apple',
    'Envy Apple',
    'SweeTango Apple',
    'Rome Beauty Apple',
    'Cameo Apple',
    'Arkansas Black Apple',
    'Northern Spy Apple',
    'Winesap Apple',
    'Gravenstein Apple',
    'Cox Orange Pippin Apple',
    'Cripps Pink Apple',
    'Enterprise Apple',
    'Liberty Apple',
    'Zestar Apple',
    'Baldwin Apple',
    'Roxbury Russet Apple',
    'Esopus Spitzenburg Apple',
    'Newtown Pippin Apple',
    'Rhode Island Greening Apple',
    'Yellow Transparent Apple',
    'Wolf River Apple',
    'Twenty Ounce Apple',
    'Blue Pearmain Apple',
    'Calville Blanc Apple',
    'Winter Banana Apple',
  ];

  // Detailed descriptions of apple varieties
  static const Map<String, String> appleDescriptions = {
    'Fuji Apple': 'Sweet and crispy apple variety from Japan. Known for its honey-sweet flavor and excellent storage capabilities. Originally developed at the Tohoku Research Station in Fujisaki, Japan.',
    'Gala Apple': 'Mildly sweet and vanilla-like flavor profile. Heart-shaped with distinctive striped or mottled skin. Originally from New Zealand, named after Queen Elizabeth II ("Gala" means "celebration").',
    'Honeycrisp Apple': 'Exceptionally crisp and juicy texture with balanced sweet-tart flavor. Developed by the University of Minnesota\'s apple breeding program.',
    'Granny Smith Apple': 'Tart, crisp green apple originating in Australia. Named after Maria Ann Smith, who propagated the cultivar from a chance seedling.',
    'Red Delicious Apple': 'Sweet taste with mild flavor and distinctive elongated shape with five points at the base. Originally discovered in Iowa.',
    'Golden Delicious Apple': 'Sweet, mellow flavor with a tender, yellow-gold skin. Despite its name, not related to Red Delicious. Discovered in West Virginia.',
    'Pink Lady Apple': 'Also known as Cripps Pink, characterized by its pink-red blush over a green background. Developed in Western Australia.',
    'Braeburn Apple': 'Rich, spicy-sweet flavor with firm, crisp texture. Discovered in New Zealand as a chance seedling.',
    'Jazz Apple': 'Cross between Royal Gala and Braeburn. Known for its hard, crisp texture and sweet-sharp flavor.',
    'Empire Apple': 'Cross between McIntosh and Red Delicious. Deep red color with firm, crispy flesh.',
    'McIntosh Apple': 'Sweet but tart apple with tender flesh. Discovered by John McIntosh in Ontario, Canada.',
    'Jonagold Apple': 'Blend of Jonathan and Golden Delicious varieties. Known for its honeyed flavor.',
    'Cortland Apple': 'Sweet apple with bright red skin and very white flesh that resists browning.',
    'Cosmic Crisp Apple': 'New variety developed at Washington State University. Known for its crisp texture and long shelf life.',
    'Ambrosia Apple': 'Sweet honey flavor with minimal acidity. Discovered in British Columbia.',
    'Opal Apple': 'Sweet flavor with hints of pear. Naturally resistant to browning.',
    'Envy Apple': 'Cross between Braeburn and Royal Gala. Sweet flavor with balanced acidity.',
    'SweeTango Apple': 'Cross between Honeycrisp and Zestar. Known for its sweet-tart flavor and crunch.',
    'Rome Beauty Apple': 'Mildly sweet flavor, known for being an excellent baking apple.',
    'Cameo Apple': 'Sweet-tart flavor with crisp texture. Discovered in Washington state.',
  };

  // Nutritional information for different apple varieties
  static const List<Map<String, dynamic>> nutritionData = [
    {
      'variety': 'Fuji Apple',
      'calories': 95,
      'sugar': '19g',
      'fiber': '4.5g',
      'protein': '0.5g',
      'fat': '0.3g',
      'carbohydrates': '25g',
      'vitamin_c': '10.3mg',
      'potassium': '195mg',
    },
    {
      'variety': 'Gala Apple',
      'calories': 90,
      'sugar': '18g',
      'fiber': '4g',
      'protein': '0.4g',
      'fat': '0.2g',
      'carbohydrates': '23g',
      'vitamin_c': '9.8mg',
      'potassium': '180mg',
    },
    {
      'variety': 'Honeycrisp Apple',
      'calories': 95,
      'sugar': '19g',
      'fiber': '4.5g',
      'protein': '0.5g',
      'fat': '0.3g',
      'carbohydrates': '25g',
      'vitamin_c': '11.0mg',
      'potassium': '200mg',
    },
    {
      'variety': 'Granny Smith Apple',
      'calories': 85,
      'sugar': '17g',
      'fiber': '4.8g',
      'protein': '0.4g',
      'fat': '0.2g',
      'carbohydrates': '22g',
      'vitamin_c': '12.0mg',
      'potassium': '190mg',
    },
    {
      'variety': 'Red Delicious Apple',
      'calories': 93,
      'sugar': '18g',
      'fiber': '4.2g',
      'protein': '0.4g',
      'fat': '0.3g',
      'carbohydrates': '24g',
      'vitamin_c': '9.5mg',
      'potassium': '185mg',
    },
  ];

  // Monthly availability and price data
  static const List<Map<String, String>> seasonalData = [
    {
      'month': 'January',
      'availability': 'High',
      'price': 'Medium',
      'storage_conditions': 'Cold storage peak',
      'best_varieties': 'Fuji, Red Delicious, Granny Smith',
      'market_demand': 'Moderate',
      'export_volume': 'High',
    },
    {
      'month': 'February',
      'availability': 'Medium',
      'price': 'Medium-High',
      'storage_conditions': 'Cold storage stable',
      'best_varieties': 'Fuji, Gala, Pink Lady',
      'market_demand': 'Moderate',
      'export_volume': 'Medium-High',
    },
    {
      'month': 'March',
      'availability': 'Medium-Low',
      'price': 'High',
      'storage_conditions': 'Cold storage declining',
      'best_varieties': 'Pink Lady, Granny Smith',
      'market_demand': 'Moderate-Low',
      'export_volume': 'Medium',
    },
    {
      'month': 'April',
      'availability': 'Low',
      'price': 'High',
      'storage_conditions': 'End of storage season',
      'best_varieties': 'Pink Lady, Granny Smith',
      'market_demand': 'Low',
      'export_volume': 'Low',
    },
    {
      'month': 'May',
      'availability': 'Very Low',
      'price': 'Very High',
      'storage_conditions': 'New season preparation',
      'best_varieties': 'Limited varieties',
      'market_demand': 'Very Low',
      'export_volume': 'Very Low',
    },
    {
      'month': 'June',
      'availability': 'Very Low',
      'price': 'Very High',
      'storage_conditions': 'Early varieties begin',
      'best_varieties': 'Early harvest varieties',
      'market_demand': 'Low',
      'export_volume': 'Very Low',
    },
    {
      'month': 'July',
      'availability': 'Low',
      'price': 'High',
      'storage_conditions': 'Early harvest season',
      'best_varieties': 'Early harvest varieties',
      'market_demand': 'Medium',
      'export_volume': 'Low',
    },
    {
      'month': 'August',
      'availability': 'Medium',
      'price': 'Medium-High',
      'storage_conditions': 'Peak harvest begins',
      'best_varieties': 'Gala, Early Fuji',
      'market_demand': 'High',
      'export_volume': 'Medium',
    },
    {
      'month': 'September',
      'availability': 'High',
      'price': 'Medium',
      'storage_conditions': 'Peak harvest season',
      'best_varieties': 'Multiple varieties available',
      'market_demand': 'Very High',
      'export_volume': 'High',
    },
    {
      'month': 'October',
      'availability': 'Very High',
      'price': 'Low',
      'storage_conditions': 'Fresh harvest peak',
      'best_varieties': 'All varieties',
      'market_demand': 'Very High',
      'export_volume': 'Very High',
    },
    {
      'month': 'November',
      'availability': 'High',
      'price': 'Low-Medium',
      'storage_conditions': 'Early storage season',
      'best_varieties': 'All varieties',
      'market_demand': 'High',
      'export_volume': 'High',
    },
    {
      'month': 'December',
      'availability': 'High',
      'price': 'Medium',
      'storage_conditions': 'Cold storage optimal',
      'best_varieties': 'All varieties',
      'market_demand': 'High',
      'export_volume': 'High',
    },
  ];

  // Growing conditions and requirements
  static const Map<String, List<String>> growingConditions = {
    'soil_types': [
      'Well-draining loamy soil',
      'Sandy loam',
      'Clay loam',
      'Rich organic soil',
      'pH 6.0-7.0',
      'Moderate fertility',
      'Good moisture retention',
      'Adequate drainage essential',
    ],
    'climate_requirements': [
      'Cold winter period for dormancy',
      'Minimum 500-1000 chill hours',
      'Full sun exposure',
      'Protection from strong winds',
      'Moderate humidity',
      'Annual rainfall 900-1200mm',
      'Spring frost protection',
      'Good air circulation',
    ],
    'spacing_requirements': [
      'Standard trees: 25-30 feet apart',
      'Semi-dwarf: 12-15 feet apart',
      'Dwarf trees: 6-8 feet apart',
      'Row spacing: 20-25 feet',
      'Intensive systems: 3-4 feet',
      'Training system dependent',
      'Rootstock influenced',
      'Soil fertility dependent',
    ],
  };

  // Pest and disease information
  static const List<Map<String, String>> pestAndDiseaseData = [
    {
      'name': 'Apple Scab',
      'type': 'Fungal Disease',
      'symptoms': 'Dark, scabby lesions on leaves and fruit',
      'treatment': 'Fungicide applications, resistant varieties',
      'prevention': 'Good sanitation, proper spacing',
      'severity': 'High',
      'season': 'Spring-Summer',
      'economic_impact': 'Significant',
    },
    {
      'name': 'Fire Blight',
      'type': 'Bacterial Disease',
      'symptoms': 'Blackened leaves, curved branch tips',
      'treatment': 'Pruning, copper sprays',
      'prevention': 'Resistant varieties, sanitation',
      'severity': 'Very High',
      'season': 'Spring',
      'economic_impact': 'Severe',
    },
    {
      'name': 'Codling Moth',
      'type': 'Insect Pest',
      'symptoms': 'Tunneling in fruit, entry/exit holes',
      'treatment': 'Insecticides, traps',
      'prevention': 'Monitoring, timing of sprays',
      'severity': 'High',
      'season': 'Spring-Fall',
      'economic_impact': 'Moderate to High',
    },
    {
      'name': 'Apple Maggot',
      'type': 'Insect Pest',
      'symptoms': 'Dimpling on fruit surface, internal tunnels',
      'treatment': 'Traps, insecticides',
      'prevention': 'Clean fallen fruit, monitoring',
      'severity': 'Moderate',
      'season': 'Summer',
      'economic_impact': 'Moderate',
    },
    {
      'name': 'Cedar Apple Rust',
      'type': 'Fungal Disease',
      'symptoms': 'Orange spots on leaves and fruit',
      'treatment': 'Fungicides, remove cedar trees',
      'prevention': 'Resistant varieties',
      'severity': 'Moderate',
      'season': 'Spring',
      'economic_impact': 'Low to Moderate',
    },
  ];

  // Storage and handling guidelines
  static const Map<String, List<String>> storageGuidelines = {
    'optimal_conditions': [
      'Temperature: 30-32°F (-1.1 to 0°C)',
      'Relative Humidity: 90-95%',
      'Air Circulation: Moderate',
      'Ethylene Production: Moderate to High',
      'Storage Life: 3-6 months',
      'Chilling Requirement: Yes',
      'Ripening Pattern: Climacteric',
      'Temperature Sensitivity: Moderate',
    ],
    'handling_practices': [
      'Handle fruit carefully to prevent bruising',
      'Pick at proper maturity stage',
      'Pre-cool quickly after harvest',
      'Sort and grade before storage',
      'Remove damaged fruit promptly',
      'Monitor storage conditions regularly',
      'Maintain cleanliness in storage',
      'Use proper storage containers',
    ],
    'quality_indicators': [
      'Firmness',
      'Color development',
      'Sugar content',
      'Starch conversion',
      'Internal ethylene',
      'Pressure test results',
      'Background color',
      'Watercore presence',
    ],
  };

  // Processing and culinary uses
  static const List<Map<String, List<String>>> culinaryUses = [
    {
      'fresh_eating': [
        'Out of hand consumption',
        'Sliced in salads',
        'Paired with cheese',
        'School lunches',
        'Snack platters',
        'Fruit arrangements',
        'Sports activities',
        'Office snacks',
      ],
      'baking': [
        'Apple pies',
        'Apple crisps',
        'Muffins',
        'Cakes',
        'Tarts',
        'Strudels',
        'Turnovers',
        'Dumplings',
      ],
      'cooking': [
        'Applesauce',
        'Baked apples',
        'Chutney',
        'Savory dishes',
        'Braising',
        'Stuffing',
        'Compotes',
        'Glazes',
      ],
    },
  ];

  // Historical significance and cultural importance
  static const Map<String, List<String>> historicalData = {
    'origin': [
      'Native to Central Asia',
      'Spread via Silk Road',
      'Ancient cultivation history',
      'Roman Empire distribution',
      'Medieval monastery gardens',
      'Colonial American importance',
      'Johnny Appleseed legacy',
      'Modern breeding programs',
    ],
    'cultural_significance': [
      'Biblical connections',
      'Norse mythology',
      'Greek mythology',
      'Traditional medicine',
      'Holiday traditions',
      'Cultural symbols',
      'Educational uses',
      'Agricultural heritage',
    ],
    'economic_history': [
      'Traditional trade routes',
      'Colonial export commodity',
      'Industrial revolution impact',
      'Modern global trade',
      'Regional economies',
      'Labor history',
      'Technology development',
      'Market evolution',
    ],
  };

  // Economic data and market trends
  static const List<Map<String, dynamic>> marketData = [
    {
      'year': 2020,
      'global_production': '86.1 million tonnes',
      'leading_producers': [
        'China',
        'United States',
        'Turkey',
        'Poland',
        'India'
      ],
      'export_value': '8.5 billion USD',
      'market_trends': [
        'Organic growth',
        'Local sourcing',
        'New varieties',
        'Value-added products'
      ],
    },
    {
      'year': 2021,
      'global_production': '87.2 million tonnes',
      'leading_producers': [
        'China',
        'United States',
        'Turkey',
        'Poland',
        'India'
      ],
      'export_value': '9.1 billion USD',
      'market_trends': [
        'Sustainable practices',
        'Premium varieties',
        'Health awareness',
        'Processing innovation'
      ],
    },
    {
      'year': 2022,
      'global_production': '88.5 million tonnes',
      'leading_producers': [
        'China',
        'United States',
        'Turkey',
        'Poland',
        'India'
      ],
      'export_value': '9.8 billion USD',
      'market_trends': [
        'Climate adaptation',
        'Digital farming',
        'Brand development',
        'Export expansion'
      ],
    },
  ];

  // Research and development focuses
  static const Map<String, List<String>> researchAreas = {
    'breeding_objectives': [
      'Disease resistance',
      'Climate adaptation',
      'Flavor enhancement',
      'Storage longevity',
      'Tree architecture',
      'Yield improvement',
      'Color development',
      'Nutrition enhancement',
    ],
    'production_technology': [
      'Precision agriculture',
      'Automated harvesting',
      'Irrigation systems',
      'Plant protection',
      'Growth regulation',
      'Rootstock development',
      'Training systems',
      'Soil management',
    ],
    'post_harvest': [
      'Storage technology',
      'Quality preservation',
      'Packaging innovation',
      'Transportation systems',
      'Ripening control',
      'Decay prevention',
      'Energy efficiency',
      'Waste reduction',
    ],
  };

  // Environmental impact and sustainability
  static const List<Map<String, String>> environmentalData = [
    {
      'aspect': 'Water Usage',
      'impact': 'Moderate',
      'mitigation': 'Drip irrigation, soil moisture monitoring',
      'sustainability_measures': 'Water recycling, drought-resistant rootstocks',
      'future_challenges': 'Climate change, water scarcity',
      'research_needs': 'Water efficiency improvement',
    },
    {
      'aspect': 'Pesticide Use',
      'impact': 'Moderate to High',
      'mitigation': 'IPM programs, biological control',
      'sustainability_measures': 'Resistant varieties, monitoring systems',
      'future_challenges': 'Pest resistance, regulation changes',
      'research_needs': 'Alternative control methods',
    },
    {
      'aspect': 'Soil Health',
      'impact': 'Variable',
      'mitigation': 'Cover crops, organic matter management',
      'sustainability_measures': 'Reduced tillage, composting',
      'future_challenges': 'Soil degradation, erosion',
      'research_needs': 'Soil biology understanding',
    },
    {
      'aspect': 'Biodiversity',
      'impact': 'Moderate',
      'mitigation': 'Habitat preservation, beneficial insects',
      'sustainability_measures': 'Diverse plantings, wildlife corridors',
      'future_challenges': 'Habitat loss, species decline',
      'research_needs': 'Ecosystem services evaluation',
    },
    {
      'aspect': 'Carbon Footprint',
      'impact': 'Moderate',
      'mitigation': 'Energy efficiency, local marketing',
      'sustainability_measures': 'Carbon sequestration, renewable energy',
      'future_challenges': 'Emissions regulations, market demands',
      'research_needs': 'Carbon neutral production',
    },
  ];

  // Industry certifications and standards
  static const Map<String, List<String>> certificationStandards = {
    'quality_standards': [
      'USDA Grades',
      'GlobalG.A.P.',
      'Organic certification',
      'Fair Trade',
      'ISO 9001',
      'HACCP compliance',
      'BRC certification',
      'Regional standards',
    ],
    'sustainability_certifications': [
      'Rainforest Alliance',
      'Sustainable agriculture',
      'Carbon neutral',
      'Water stewardship',
      'Biodiversity friendly',
      'Social responsibility',
      'Environmental management',
      'Energy efficiency',
    ],
    'safety_certifications': [
      'Food safety systems',
      'Worker safety',
      'Pesticide handling',
      'Storage facility',
      'Transportation safety',
      'Processing safety',
      'Packaging safety',
      'Retail safety',
    ],
  };
}