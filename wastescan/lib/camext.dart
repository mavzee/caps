import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'educ.dart'; // Import the EducPage
import 'quiz.dart'; // Import the QuizPage

class CamPage extends StatefulWidget {
  const CamPage({super.key});

  @override
  _CamPageState createState() => _CamPageState();
}

class _CamPageState extends State<CamPage> {
  File? _image;
  String? _prediction;
  String? _recyclableOutput; // To store recyclable output
  int _selectedIndex = 0; // Index for bottom navigation bar

  // Mapping of waste types to recyclable outputs
  final Map<String, String> _recyclableOutputs = {
    'plastic': '''
**How to Recycle:**
- Clean plastic items thoroughly before recycling.
- Remove any non-recyclable parts (e.g., caps, labels).
- Check your local recycling guidelines for specific instructions.

**What It Can Be Turned Into:**
- New bottles and containers
- Clothing and textiles
- Furniture and outdoor decks
- Packaging materials
''',
    'paper': '''
**How to Recycle:**
- Remove any contaminants like food or grease.
- Flatten cardboard boxes to save space.
- Separate colored paper from white paper if required.

**What It Can Be Turned Into:**
- New notebooks and stationery
- Cardboard boxes and packaging
- Newspapers and magazines
- Insulation materials
''',
    'metal': '''
**How to Recycle:**
- Rinse metal cans to remove food residue.
- Separate aluminum and steel items if required.
- Remove any non-metal parts (e.g., plastic lids).

**What It Can Be Turned Into:**
- New cans and containers
- Appliances and electronics
- Construction materials
- Automotive parts
''',
    'glass': '''
**How to Recycle:**
- Rinse glass containers to remove any residue.
- Separate by color (clear, green, brown) if required.
- Do not include broken glass or ceramics.

**What It Can Be Turned Into:**
- New bottles and jars
- Countertops and tiles
- Decorative items and art
- Fiberglass insulation
''',
    'cardboard': '''
**How to Recycle:**
- Flatten cardboard boxes to save space.
- Remove any tape or stickers.
- Keep dry and free from food contamination.

**What It Can Be Turned Into:**
- New cardboard boxes
- Packaging materials
- Paperboard products (e.g., cereal boxes)
- Insulation materials
''',
    'organic': '''
**How to Recycle:**
- Compost organic waste in a compost bin or pile.
- Avoid adding meat, dairy, or oily foods.
- Mix with yard waste like leaves and grass clippings.

**What It Can Be Turned Into:**
- Nutrient-rich compost for gardening
- Soil amendments for agriculture
- Mulch for landscaping
''',
    'electronic': '''
**How to Recycle:**
- Take e-waste to a certified recycling facility.
- Remove batteries and dispose of them separately.
- Wipe personal data from devices before recycling.

**What It Can Be Turned Into:**
- Recovered metals (e.g., gold, copper)
- New electronics and appliances
- Raw materials for manufacturing
''',
    'bottle': '''
**How to Recycle:**
- Rinse the bottle to remove any liquid or residue.
- Remove the cap and label if they are not recyclable.
- Place the bottle in the recycling bin.

**What It Can Be Turned Into:**
- New plastic bottles
- Clothing and textiles
- Outdoor furniture
- Packaging materials
''',
   'can': '''
**How to Recycle:**
- Rinse the bottle to remove any liquid or residue.
- Remove the cap and label if they are not recyclable.
- Place the bottle in the recycling bin.

**What It Can Be Turned Into:**
- can
-chair
- Outdoor furniture
- Packaging materials
''',
  };

  // Method to pick an image from the camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      _sendImageToServer(_image!);
    }
  }

  // Method to send the image to the backend for prediction
  Future<void> _sendImageToServer(File image) async {
    try {
      var request = http.MultipartRequest(
        'POST',
       // In _sendImageToServer method, update this line:
        Uri.parse('http://192.168.1.11:5000/predict'),  // Use the IP from Flask output // Replace with your backend IP
      );

      request.files.add(await http.MultipartFile.fromPath('file', image.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var result = jsonDecode(responseData);

        // Check if the 'predictions' key exists in the response
        if (result.containsKey('predictions') && result['predictions'].isNotEmpty) {
          String wasteType = result['predictions'][0]['class']; // Extract the prediction
          String recyclableOutput = _recyclableOutputs[wasteType.toLowerCase()] ?? "No information available";

          setState(() {
            _prediction = wasteType;
            _recyclableOutput = recyclableOutput; // Set recyclable output
          });
        } else {
          setState(() {
            _prediction = "Error: No predictions found";
            _recyclableOutput = ""; // Clear recyclable output
          });
        }
      } else {
        setState(() {
          _prediction = "The Item should be clear and steady (Status: ${response.statusCode})";
          _recyclableOutput = ""; // Clear recyclable output
        });
      }
    } catch (e) {
      setState(() {
        _prediction = "Error: $e";
        _recyclableOutput = ""; // Clear recyclable output
      });
    }
  }

  // Method to handle bottom navigation bar item taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Handle navigation based on the selected index
    if (index == 0) {
      // If book icon is clicked
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EducPage()), // Navigate to EducPage
      );
    } else if (index == 1) {
      // If lightbulb is clicked
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const QuizPage()), // Navigate to QuizPage
      );
    } else if (index == 2) {
      // If camera is clicked, do nothing (already on CamPage)
    } else if (index == 3) {
      // If person icon is clicked, navigate to ProfilePage (if needed)
      // Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Waste Scanner',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[700], // Dark green for the app bar
        elevation: 10, // Add shadow
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context); // Navigate back to the previous screen
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Image Section
            _image == null
                ? const Text(
                    'No image selected.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  )
                : Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(
                        _image!,
                        fit: BoxFit.cover,
                        height: 200,
                        width: double.infinity,
                      ),
                    ),
                  ),
            const SizedBox(height: 20),

            // Prediction Section
            if (_prediction != null)
              Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prediction: $_prediction',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Recycling Information:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _recyclableOutput ?? "The item should be clear and steady",
                        style: const TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Buttons Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt, size: 24),
                  label: const Text('Take a Picture'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 68, 223, 76),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library, size: 24),
                  label: const Text('Pick from Gallery'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 68, 223, 76),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.book),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.lightbulb),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.camera),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: '',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.green[700],
            unselectedItemColor: Colors.grey,
            onTap: _onItemTapped,
            showSelectedLabels: false,
            showUnselectedLabels: false,
          ),
        ),
      ),
    );
  }
}