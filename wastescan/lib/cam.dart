import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'educ.dart';
import 'quiz.dart';

class CamPage extends StatefulWidget {
  const CamPage({super.key});

  @override
  State<CamPage> createState() => _CamPageState();
}

class _CamPageState extends State<CamPage> {
  File? _image;
  String? _prediction;
  String? _recyclableOutput;
  int _selectedIndex = 2;
  bool _isLoading = false;
  double? _confidence;
  String? _manualWasteType;
  bool _showManualInput = false;
  final TextEditingController _manualInputController = TextEditingController();
  
  // Test different IP addresses - uncomment the one that works
  // final String _serverUrl = 'http://192.168.1.33:5000/predict'; // Your current IP
   // final String _serverUrl = 'http://10.0.2.2:5000/predict'; // Android emulator
  // final String _serverUrl = 'http://127.0.0.1:5000/predict'; // iOS simulator
  // final String _serverUrl = 'http://localhost:5000/predict'; // General
  final String _serverUrl = 'https://ecoquest-api.onrender.com/predict';

  final Map<String, Map<String, dynamic>> _wasteInfo = {
    'plastic': {
      'title': 'Plastic',
      'category': 'Recyclable',
      'icon': Icons.recycling,
      'color': Colors.blue,
      'instructions': '''
**How to Recycle:**
1. Clean plastic items thoroughly before recycling
2. Remove caps, lids, and non-recyclable parts
3. Check resin identification codes (1-7)
4. Flatten containers to save space

**Accepted Types:**
• PET (1) - Water bottles, food containers
• HDPE (2) - Milk jugs, detergent bottles
• PVC (3) - Pipes, credit cards
• LDPE (4) - Plastic bags, shrink wrap
• PP (5) - Yogurt containers, bottle caps
• PS (6) - Foam packaging, disposable cups
• Other (7) - Mixed plastics, some food containers

**Recycling Process:**
→ Shredding → Washing → Melting → Pelletizing → New Products

**What It Can Be Turned Into:**
• New bottles and containers
• Clothing and textiles (fleece, polyester)
• Furniture and outdoor decks
• Packaging materials
• Car parts and components
''',
    },
    'paper': {
      'title': 'Paper',
      'category': 'Recyclable',
      'icon': Icons.description,
      'color': Colors.brown,
      'instructions': '''
**How to Recycle:**
1. Remove staples, clips, and plastic windows
2. Keep dry and clean - no wet or soiled paper
3. Flatten cardboard boxes to save space
4. Separate colored paper from white paper if required

**Types of Paper:**
• Office paper (high quality)
• Newspapers and magazines
• Cardboard and corrugated boxes
• Paperboard (cereal boxes, shoe boxes)
• Junk mail and envelopes
• Paper bags and wrapping paper (non-glossy)

**Paper Recycling Process:**
Pulping → Screening → De-inking → Cleaning → Forming → Drying → New Paper

**What It Can Be Turned Into:**
• New notebooks, stationery, and office paper
• Cardboard boxes and packaging materials
• Newspapers, magazines, and books
• Egg cartons and paper tubes
• Insulation materials
• Animal bedding
''',
    },
    'metal': {
      'title': 'Metal',
      'category': 'Highly Recyclable',
      'icon': Icons.settings,
      'color': Colors.grey,
      'instructions': '''
**How to Recycle:**
1. Rinse metal cans to remove food residue
2. Remove paper labels if possible
3. Keep aluminum and steel items separate if required
4. Remove any non-metal parts (plastic lids, etc.)
5. No aerosol cans with pressure remaining

**Metal Types:**
• Aluminum (soda cans, foil, food trays)
• Steel (food cans, aerosol cans, appliances)
• Tin (rare, often coated on steel)
• Scrap metal (wires, pipes, fixtures)

**Recycling Benefits:**
♻️ Saves 95% energy compared to new production
♻️ Infinite recyclability without quality loss
♻️ Reduces mining and environmental impact
♻️ Conserves natural resources

**What It Can Be Turned Into:**
• New cans and containers
• Appliances and electronics
• Construction materials (beams, rebar)
• Automotive parts (car bodies, engines)
• Bicycles and furniture
• Industrial machinery
''',
    },
    'glass': {
      'title': 'Glass',
      'category': 'Fully Recyclable',
      'icon': Icons.wine_bar,
      'color': Colors.green,
      'instructions': '''
**How to Recycle:**
1. Rinse glass containers to remove any residue
2. Sort by color (clear, green, brown) if required
3. Remove metal caps and rings
4. Do not include broken glass or ceramics
5. No window glass, mirrors, or Pyrex

**Color Sorting:**
• Clear (flint) - Most valuable, bottles, jars
• Green (emerald) - Wine bottles, beer bottles
• Brown (amber) - Beer bottles, medicine bottles

**Glass Recycling Process:**
Crushing → Mixing with raw materials → Melting at high temperature → Molding → New Glass

**What It Can Be Turned Into:**
• New bottles and jars
• Countertops and tiles
• Decorative items and art glass
• Fiberglass insulation
• Abrasives and filtration media
• Road construction materials (glassphalt)
''',
    },
    'cardboard': {
      'title': 'Cardboard',
      'category': 'Recyclable',
      'icon': Icons.inventory,
      'color': Colors.brown[800]!,
      'instructions': '''
**How to Recycle:**
1. Flatten cardboard boxes to save space
2. Remove any tape, stickers, or labels
3. Keep dry and free from food contamination
4. Break down large boxes into manageable pieces
5. Remove any plastic liners or packing materials

**Types of Cardboard:**
• Corrugated cardboard (wavy middle layer) - Shipping boxes
• Paperboard (cereal boxes, shoe boxes) - Thin, smooth
• Chipboard (backing for notepads) - Very thin
• Greyboard (packaging for electronics) - Dense and sturdy

**Cardboard Recycling Process:**
Shredding → Pulping → Screening → Forming → Pressing → Drying → New Cardboard

**What It Can Be Turned Into:**
• New cardboard boxes and packaging
• Paperboard products (cereal boxes, tissue boxes)
• Paper towels and napkins
• Egg cartons and fruit trays
• Animal bedding and insulation
• Construction paper and craft materials
''',
    },
    'organic': {
      'title': 'Organic Waste',
      'category': 'Compostable',
      'icon': Icons.eco,
      'color': Colors.green[800]!,
      'instructions': '''
**How to Compost:**
1. Collect fruit and vegetable scraps in a compost bin
2. Add yard waste like leaves and grass clippings
3. Layer green (nitrogen) and brown (carbon) materials
4. Turn the compost regularly for aeration
5. Keep moist but not soggy

**What to Compost:**
✓ Fruit and vegetable scraps
✓ Coffee grounds and filters
✓ Eggshells (crushed)
✓ Yard trimmings (grass, leaves)
✓ Tea bags (remove staples)
✓ Shredded paper and cardboard

**What NOT to Compost:**
✗ Meat, fish, or bones
✗ Dairy products
✗ Oily or greasy foods
✗ Pet waste
✗ Diseased plants
✗ Coal or charcoal ash

**Composting Process:**
Collection → Layering → Decomposition → Curing → Finished Compost

**Benefits of Composting:**
• Reduces landfill waste by 30%
• Creates nutrient-rich fertilizer for gardens
• Improves soil structure and water retention
• Reduces need for chemical fertilizers
• Lowers greenhouse gas emissions
''',
    },
    'electronic': {
      'title': 'E-Waste',
      'description': 'Electronics, batteries, cables, and devices',
      'category': 'Special Handling',
      'icon': Icons.devices,
      'color': Colors.purple,
      'instructions': '''
**Safety First:**
• Remove batteries from devices first
• Wipe personal data from phones and computers
• Bundle cables together with rubber bands
• Check for manufacturer take-back programs
• Store in a dry place until disposal

**Accepted E-Waste:**
- Computers, laptops, and tablets
- Phones, smartphones, and landlines
- TVs, monitors, and display screens
- Printers, scanners, and copiers
- Small appliances (toasters, blenders)
- Cables, chargers, and power strips
- Batteries (separate collection)
- Audio/video equipment

**Proper Disposal:**
1. Take to certified e-waste recycler
2. Do not throw in regular trash
3. Remove batteries for separate recycling
4. Check local electronics retailer take-back programs
5. Some municipalities offer special collection days

**What Can Be Recovered:**
• Precious metals (gold, silver, palladium)
• Base metals (copper, aluminum, steel)
• Glass from monitors and screens
• Plastics for recycling
• Rare earth elements

**Environmental Impact:**
⚠️ E-waste contains toxic materials (lead, mercury)
⚠️ Proper recycling prevents soil and water contamination
⚠️ Recovers valuable resources for reuse
''',
    },
    'battery': {
      'title': 'Batteries',
      'category': 'Hazardous',
      'icon': Icons.battery_alert,
      'color': Colors.red,
      'instructions': '''
**⚠️ IMPORTANT SAFETY ⚠️**
• Tape terminals of 9V and lithium batteries
• Store in non-metal container with lid
• Keep away from heat sources and sunlight
• Never crush, puncture, or modify batteries
• Keep out of reach of children and pets

**Battery Types & Disposal:**
• Alkaline (AA, AAA, C, D) - Regular trash in most areas
• Lithium-ion (phones, laptops, power tools) - Special recycling
• Lead-acid (cars, motorcycles) - Auto parts stores accept
• Button cells (watches, hearing aids) - Jewelry stores often accept
• Rechargeable (NiMH, NiCd) - Special recycling required
• Car batteries - Return to retailer or auto shop

**Battery Recycling Process:**
Sorting → Crushing → Separation → Chemical processing → Material recovery

**Recovered Materials:**
• Steel, aluminum, and other metals
• Lithium, cobalt, and nickel
• Plastic casings
• Chemical compounds for new batteries

**Danger of Improper Disposal:**
🔥 Fire hazard from short circuits
💀 Toxic chemical leakage
🌍 Soil and water contamination
💰 Lost valuable resources
''',
    },
    'stone': {
      'title': 'Stone/Rock',
      'category': 'Non-Recyclable',
      'icon': Icons.landscape,
      'color': Colors.brown[600]!,
      'instructions': '''
**Disposal Instructions:**
• Small stones and rocks can be disposed of with regular trash
• For large amounts (landscaping debris), contact a waste removal service
• Consider reusing stones for landscaping before disposal
• Check if local recycling centers accept clean concrete

**Reuse Ideas:**
→ Use for garden landscaping and pathways
→ Create rock gardens or decorative borders
→ Use as drainage material in plant pots
→ Build retaining walls or rock features
→ Use in crafts or DIY projects

**Recycling Possibilities:**
• Crushed stone can be used as aggregate in concrete
• Clean, uniform stones may be reusable in construction
• Some facilities accept concrete and masonry for recycling

**What NOT to Do:**
✗ Don't dump in natural areas or water bodies
✗ Don't mix with regular recyclables
✗ Don't burn or attempt to break down chemically

**Alternative Disposal:**
• Contact local landscaping companies for reuse
• Check with construction companies for potential use
• Consider donating usable stones for community projects
''',
    },
    'wood': {
      'title': 'Wood/Stick',
      'category': 'Compostable/Reusable',
      'icon': Icons.forest,
      'color': Colors.brown[900]!,
      'instructions': '''
**How to Handle Wood Waste:**
1. Clean, untreated wood can be composted or used as mulch
2. Small sticks and branches can go in yard waste
3. Large pieces may need special disposal
4. Painted or treated wood requires special handling

**Types of Wood Waste:**
• Untreated wood scraps - Compost or yard waste
• Sticks and branches - Yard waste collection
• Sawdust and wood chips - Compost material
• Painted/treated wood - Special hazardous waste
• Large branches/trees - Municipal yard waste

**Reuse Ideas:**
→ Use as garden stakes for plants
→ Create kindling for fireplaces
→ Make crafts or DIY projects
→ Use as mulch in garden beds
→ Build compost bin structures

**Composting Wood:**
• Chop or shred into small pieces
• Mix with green materials for balance
• Allow longer decomposition time (6-12 months)
• Excellent for creating "brown" compost material

**Recycling Options:**
• Some facilities process clean wood into mulch
• Wood can be chipped for landscaping use
• Untreated wood may be accepted at biomass facilities
''',
    },
    'ceramic': {
      'title': 'Ceramic/Tile',
      'category': 'Non-Recyclable',
      'icon': Icons.breakfast_dining,
      'color': Colors.orange[800]!,
      'instructions': '''
**Disposal Instructions:**
• Ceramics, pottery, and tiles go in regular trash
• Wrap broken pieces in newspaper for safety
• Large amounts may require special disposal
• Consider reuse before disposal

**What is Ceramic Waste:**
• Broken dishes, cups, and plates
• Pottery and clay items
• Ceramic tiles (floor, wall)
• Porcelain fixtures
• Toilets and sinks (large items)

**Reuse Ideas:**
→ Use broken pieces for mosaic art projects
→ Use as drainage material in plant pots
→ Create garden markers or decorations
→ Use tiles for crafts or DIY home projects
→ Donate usable items to thrift stores

**Recycling Challenges:**
• Cannot be melted down like glass
• Different melting point than glass recyclables
• Often contains glazes and coatings
• Heavy and difficult to transport

**Special Notes:**
• Some facilities accept clean ceramics for crushing into aggregate
• Check with local construction recycling centers
• Large amounts may be accepted at landfill transfer stations
• Never mix with glass recycling - contaminates entire batch
''',
    },
    'textile': {
      'title': 'Textile/Cloth',
      'category': 'Reusable/Recyclable',
      'icon': Icons.checkroom,
      'color': Colors.purple[300]!,
      'instructions': '''
**How to Recycle Textiles:**
1. Clean and dry all textiles before recycling
2. Separate by type (clothing, linens, fabrics)
3. Remove any non-textile parts (buttons, zippers)
4. Check for local textile recycling programs

**Textile Categories:**
• Wearable clothing - Donate to charities
• Damaged clothing - Textile recycling bins
• Bed linens and towels - Animal shelters often accept
• Fabric scraps - Some craft stores accept
• Shoes and accessories - Special recycling programs

**Reuse Hierarchy:**
1. Wear/Use - Continue using items
2. Donate - Give to those in need
3. Repurpose - Turn into cleaning rags, crafts
4. Recycle - Textile recycling facilities

**Textile Recycling Process:**
Sorting → Grading → Shredding → Fiber processing → New products

**What Textiles Become:**
• Insulation material for homes and cars
• Wiping rags for industrial use
• Carpet padding and underlay
• New yarn and fabrics (downcycling)
• Soundproofing materials

**Donation Tips:**
• Wash and fold items neatly
• Pair shoes together
• Check charity guidelines first
• Some offer pickup services
• Get donation receipts for taxes
''',
    },
    'unknown': {
      'title': 'Unknown Item',
      'category': 'Needs Identification',
      'icon': Icons.help,
      'color': Colors.grey,
      'instructions': '''
**Unable to identify this item automatically.**

**Please help us identify it:**
1. Take a clearer photo with better lighting
2. Ensure the item is centered and in focus
3. Remove background clutter
4. Or manually enter what type of waste this is below

**Common Waste Types:**
• Plastic, Paper, Metal, Glass
• Cardboard, Organic, Electronic
• Battery, Stone, Wood, Ceramic
• Textile, Rubber, Composite

**Tips for Better Photos:**
📸 Use natural light if possible
📸 Fill the frame with the waste item
📸 Take photos from multiple angles
📸 Avoid shadows and glare
📸 Show any labels or markings

**Manual Identification Available:**
You can manually enter what type of waste you think this is. Our system will provide appropriate recycling information based on your input.
''',
    },
  };

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _prediction = null;
          _recyclableOutput = null;
          _confidence = null;
          _manualWasteType = null;
          _showManualInput = false;
        });

        await _sendImageToServer(_image!);
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _sendImageToServer(File image) async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('🚀 Starting image upload...');
      print('📱 Image path: ${image.path}');
      print('🌐 Server URL: $_serverUrl');

      List<int> imageBytes = await image.readAsBytes();
      print('📊 Image size: ${imageBytes.length} bytes');

      String base64Image = base64Encode(imageBytes);
      print('🔢 Base64 encoded: ${base64Image.length} characters');

      var response = await http.post(
        Uri.parse(_serverUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'image': base64Image,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        }),
      ).timeout(const Duration(seconds: 45));

      print('✅ Response received');
      print('📡 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        print('🎯 Parsed Result: $result');

        if (result.containsKey('predictions') && result['predictions'].isNotEmpty) {
          var prediction = result['predictions'][0];
          String wasteType = prediction['class']?.toString().toLowerCase() ?? 'unknown';
          double confidence = (prediction['confidence'] ?? 0.0).toDouble();

          print('🎯 Detected: $wasteType');
          print('📊 Confidence: $confidence');

          String matchedType = _findBestMatch(wasteType);
          var wasteData = _wasteInfo[matchedType] ?? _wasteInfo['unknown']!;

          setState(() {
            _prediction = wasteData['title'];
            _recyclableOutput = wasteData['instructions'];
            _confidence = confidence;
          });

          if (confidence < 0.3 || matchedType == 'unknown') {
            // Low confidence or unknown - ask user for manual input
            Future.delayed(const Duration(milliseconds: 500), () {
              _showManualInputDialog();
            });
          } else if (confidence < 0.6) {
            _showWarning('Low confidence (${(confidence * 100).toStringAsFixed(0)}%). Please verify the identification.');
          }
        } else {
          print('⚠️ No predictions in response');
          setState(() {
            _prediction = 'Unknown';
            _recyclableOutput = _wasteInfo['unknown']!['instructions'];
            _confidence = 0.0;
          });
          // Show manual input dialog for unknown items
          Future.delayed(const Duration(milliseconds: 500), () {
            _showManualInputDialog();
          });
        }
      } else {
        print('❌ Server error: ${response.statusCode}');
        _showError('Server error: ${response.statusCode}\n${response.body}');
      }
    } on TimeoutException catch (_) {
      print('⏰ Timeout exception');
      _showError('Server timeout. Please check:\n1. Server is running\n2. Correct IP address\n3. Same WiFi network');
    } on SocketException catch (e) {
      print('🔌 Socket exception: $e');
      _showError('Cannot connect to server.\nCheck IP: $_serverUrl\nEnsure server is running');
    } on http.ClientException catch (e) {
      print('🌐 HTTP Client exception: $e');
      _showError('Network error: $e\nCheck internet connection');
    } catch (e) {
      print('❌ Error: $e');
      _showError('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showManualInputDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Help Identify This Waste'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('The AI needs your help to identify this item.'),
                const SizedBox(height: 10),
                const Text('What type of waste is this?'),
                const SizedBox(height: 20),
                TextField(
                  controller: _manualInputController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'e.g., paper, stone, ceramic, wood, cardboard...',
                    labelText: 'Waste Type',
                  ),
                  onChanged: (value) {
                    _manualWasteType = value.trim().toLowerCase();
                  },
                ),
                const SizedBox(height: 15),
                const Text('Common waste types:'),
                Wrap(
                  spacing: 8.0,
                  children: [
                    _buildChip('plastic', () {
                      _manualInputController.text = 'plastic';
                      _manualWasteType = 'plastic';
                    }),
                    _buildChip('paper', () {
                      _manualInputController.text = 'paper';
                      _manualWasteType = 'paper';
                    }),
                    _buildChip('cardboard', () {
                      _manualInputController.text = 'cardboard';
                      _manualWasteType = 'cardboard';
                    }),
                    _buildChip('metal', () {
                      _manualInputController.text = 'metal';
                      _manualWasteType = 'metal';
                    }),
                    _buildChip('glass', () {
                      _manualInputController.text = 'glass';
                      _manualWasteType = 'glass';
                    }),
                    _buildChip('wood', () {
                      _manualInputController.text = 'wood';
                      _manualWasteType = 'wood';
                    }),
                    _buildChip('stone', () {
                      _manualInputController.text = 'stone';
                      _manualWasteType = 'stone';
                    }),
                    _buildChip('ceramic', () {
                      _manualInputController.text = 'ceramic';
                      _manualWasteType = 'ceramic';
                    }),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Skip'),
              onPressed: () {
                _manualInputController.clear();
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Identify'),
              onPressed: () {
                if (_manualWasteType != null && _manualWasteType!.isNotEmpty) {
                  _handleManualIdentification(_manualWasteType!);
                  Navigator.of(context).pop();
                } else {
                  _showError('Please enter a waste type');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Chip(
        label: Text(label),
        backgroundColor: Colors.green[100],
        labelStyle: TextStyle(color: Colors.green[800]),
      ),
    );
  }

  void _handleManualIdentification(String userInput) {
    String matchedType = _findBestMatch(userInput);
    var wasteData = _wasteInfo[matchedType] ?? _wasteInfo['unknown']!;

    setState(() {
      _prediction = wasteData['title'];
      _recyclableOutput = wasteData['instructions'];
      _confidence = 0.0; // Set to 0 since it was user-identified
      _showManualInput = false;
    });

    _showSuccess('Identified as "${wasteData['title']}" based on your input.');
    _manualInputController.clear();
  }

  Future<void> _testConnection() async {
    try {
      print('Testing connection to: $_serverUrl');
      var response = await http.get(
        Uri.parse(_serverUrl.replaceFirst('/predict', '/health')),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        _showSuccess('✅ Server connected successfully!');
        print('✅ Connection test passed');
      } else {
        _showError('Server error: ${response.statusCode}');
      }
    } on TimeoutException catch (_) {
      _showError('❌ Connection timeout\nTry:\n1. Check server IP\n2. Disable firewall\n3. Same WiFi network');
    } on SocketException catch (e) {
      _showError('Socket error: $e\nCannot connect to server');
    } on http.ClientException catch (e) {
      _showError('HTTP error: $e\nCheck network connection');
    } catch (e) {
      _showError('Connection failed: $e');
    }
  }

  String _findBestMatch(String wasteType) {
    wasteType = wasteType.toLowerCase();
    
    // First, try exact match
    if (_wasteInfo.containsKey(wasteType)) {
      return wasteType;
    }
    
    // Try partial matches
    for (var key in _wasteInfo.keys) {
      if (wasteType.contains(key) || key.contains(wasteType)) {
        return key;
      }
    }
    
    // Extended variations for better matching
    final variations = {
      'plastic': ['pet', 'hdpe', 'ldpe', 'pp', 'ps', 'bottle', 'bag', 'container', 'wrapper', 'film', 'packaging', 'straw', 'cup', 'utensil', 'wrap', 'bubblewrap'],
      'paper': ['paper', 'cardboard', 'newspaper', 'magazine', 'office', 'carton', 'box', 'egg carton', 'tissue', 'book', 'notebook', 'envelope', 'mail', 'brochure', 'flyer'],
      'metal': ['metal', 'aluminum', 'aluminium', 'steel', 'tin', 'can', 'foil', 'soda can', 'food can', 'aerosol', 'wire', 'nail', 'screw', 'bolt', 'tool', 'utensil'],
      'glass': ['glass', 'bottle', 'jar', 'container', 'wine bottle', 'beer bottle', 'broken glass', 'mirror', 'window', 'drinking glass', 'vase'],
      'cardboard': ['cardboard', 'box', 'carton', 'corrugated', 'shipping box', 'packing box', 'moving box', 'cardboard tube'],
      'organic': ['organic', 'food', 'compost', 'fruit', 'vegetable', 'biodegradable', 'peel', 'core', 'leaves', 'yard waste', 'grass', 'weed', 'plant', 'flower', 'seed'],
      'wood': ['wood', 'stick', 'branch', 'lumber', 'timber', 'plank', 'log', 'twig', 'popsicle stick', 'chopstick', 'dowel', 'wooden'],
      'stone': ['stone', 'rock', 'gravel', 'pebble', 'boulder', 'concrete', 'brick', 'cement', 'marble', 'granite', 'slate'],
      'ceramic': ['ceramic', 'pottery', 'tile', 'porcelain', 'clay', 'dish', 'plate', 'cup', 'mug', 'bowl', 'vase', 'figurine'],
      'textile': ['textile', 'cloth', 'fabric', 'clothing', 'shirt', 'pants', 'dress', 'rag', 'garment', 'towel', 'linen', 'sheet', 'curtain', 'blanket'],
      'electronic': ['electronic', 'ewaste', 'device', 'gadget', 'phone', 'laptop', 'computer', 'tv', 'monitor', 'printer', 'cable', 'charger', 'battery'],
      'battery': ['battery', 'cell', 'powerbank', 'accumulator', 'lithium', 'alkaline', 'rechargeable'],
    };
    
    // Check variations
    for (var entry in variations.entries) {
      if (entry.value.any((variation) => wasteType.contains(variation))) {
        return entry.key;
      }
    }
    
    // Common aliases
    final aliases = {
      'trash': 'unknown',
      'garbage': 'unknown',
      'rubbish': 'unknown',
      'waste': 'unknown',
      'refuse': 'unknown',
      'litter': 'unknown',
      'debris': 'unknown',
      'scrap': 'metal',
      'tin can': 'metal',
      'soda bottle': 'plastic',
      'water bottle': 'plastic',
      'milk jug': 'plastic',
      'food container': 'plastic',
      'shopping bag': 'plastic',
      'food waste': 'organic',
      'yard waste': 'organic',
      'garden waste': 'organic',
      'paper waste': 'paper',
      'card waste': 'paper',
      'metal can': 'metal',
      'glass bottle': 'glass',
      'wine bottle': 'glass',
      'beer bottle': 'glass',
      'broken glass': 'glass',
      'cardboard box': 'cardboard',
      'shipping box': 'cardboard',
      'moving box': 'cardboard',
      'wood stick': 'wood',
      'wooden stick': 'wood',
      'tree branch': 'wood',
      'rock stone': 'stone',
      'ceramic tile': 'ceramic',
      'porcelain tile': 'ceramic',
      'clothing item': 'textile',
      'fabric item': 'textile',
      'electronic waste': 'electronic',
      'e-waste': 'electronic',
      'computer waste': 'electronic',
      'phone waste': 'electronic',
      'battery waste': 'battery',
      'used battery': 'battery',
      'dead battery': 'battery',
    };
    
    if (aliases.containsKey(wasteType)) {
      return aliases[wasteType]!;
    }
    
    return 'unknown';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _showWarning(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const EducPage()));
    } else if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const QuizPage()));
    }
  }

  Widget _buildWasteCard() {
    if (_prediction == null) return Container();
    
    var wasteData = _wasteInfo.values.firstWhere(
      (data) => data['title'] == _prediction,
      orElse: () => _wasteInfo['unknown']!,
    );
    
    Color? categoryColor = wasteData['color'];
    IconData? categoryIcon = wasteData['icon'];
    String category = wasteData['category'];

    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (categoryIcon != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: categoryColor?.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(categoryIcon, color: categoryColor, size: 32),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _prediction!,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Chip(
                        label: Text(
                          category,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: categoryColor,
                      ),
                    ],
                  ),
                ),
                if (_confidence != null && _confidence! > 0)
                  Column(
                    children: [
                      CircularProgressIndicator(
                        value: _confidence,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _confidence! > 0.7 ? Colors.green : 
                          _confidence! > 0.4 ? Colors.orange : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(_confidence! * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              'Recycling Instructions:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              child: Text(
                _recyclableOutput ?? "No information available",
                style: const TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
              ),
            ),
            const SizedBox(height: 16),
            if (_confidence != null && _confidence! < 0.3)
              ElevatedButton.icon(
                onPressed: _showManualInputDialog,
                icon: const Icon(Icons.edit),
                label: const Text('Correct Identification'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[700],
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Waste Scanner',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green[700],
        elevation: 10,
        actions: [
          IconButton(
            icon: const Icon(Icons.wifi_tethering, color: Colors.white),
            onPressed: _testConnection,
            tooltip: 'Test Server Connection',
          ),
          IconButton(
            icon: const Icon(Icons.info, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Scanning Tips'),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'For Best Results:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        const Text('✅ Ensure good lighting\n✅ Focus on one item\n✅ Remove background clutter\n✅ Take close-up photos\n✅ Center the item'),
                        const SizedBox(height: 15),
                        const Text(
                          'Supported Waste Types:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Chip(label: const Text('Plastic'), backgroundColor: Colors.blue[100]),
                            Chip(label: const Text('Paper'), backgroundColor: Colors.brown[100]),
                            Chip(label: const Text('Cardboard'), backgroundColor: Colors.brown[200]),
                            Chip(label: const Text('Metal'), backgroundColor: Colors.grey[300]),
                            Chip(label: const Text('Glass'), backgroundColor: Colors.green[100]),
                            Chip(label: const Text('Wood/Stick'), backgroundColor: Colors.brown[300]),
                            Chip(label: const Text('Stone/Rock'), backgroundColor: Colors.brown[400]),
                            Chip(label: const Text('Ceramic'), backgroundColor: Colors.orange[100]),
                            Chip(label: const Text('Textile'), backgroundColor: Colors.purple[100]),
                            Chip(label: const Text('Organic'), backgroundColor: Colors.green[200]),
                            Chip(label: const Text('Electronic'), backgroundColor: Colors.purple[200]),
                            Chip(label: const Text('Battery'), backgroundColor: Colors.red[100]),
                          ],
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'Manual Identification:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Text('If AI cannot identify, you can manually enter the waste type.'),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.camera_alt, color: Colors.green[700], size: 40),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Scan Waste',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Take photo for recycling info',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Supports: Plastic, Paper, Cardboard, Metal, Glass, Wood, Stone, Ceramic, Textile',
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[300]!, width: 2),
                color: Colors.grey[50],
              ),
              child: _image == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_camera, size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 10),
                        const Text(
                          'No image selected',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.file(_image!, fit: BoxFit.cover),
                    ),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              Column(
                children: [
                  CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.green[700]!)),
                  const SizedBox(height: 15),
                  const Text(
                    'Analyzing waste...',
                    style: TextStyle(fontSize: 16, color: Colors.green),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Server: ${_serverUrl.replaceFirst('/predict', '')}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            if (!_isLoading && _prediction != null) _buildWasteCard(),
            const SizedBox(height: 20),
            if (!_isLoading)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 10),
            if (!_isLoading && _image == null)
              TextButton.icon(
                onPressed: _testConnection,
                icon: const Icon(Icons.wifi_find),
                label: const Text('Check Server Connection'),
              ),
            if (_showManualInput)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ElevatedButton.icon(
                  onPressed: _showManualInputDialog,
                  icon: const Icon(Icons.edit_note),
                  label: const Text('Manually Identify Waste'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[700],
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Learn'),
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb), label: 'Quiz'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Scan'),
          
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[700],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  @override
  void dispose() {
    _manualInputController.dispose();
    super.dispose();
  }
}