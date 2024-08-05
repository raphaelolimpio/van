import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:demo/database/database_helper.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _StudentListScreenState createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> filteredStudents = [];
  List<Map<String, dynamic>> vans = [];
  DatabaseHelper dbHelper = DatabaseHelper();
  int? selectedVanId;

  @override
  void initState() {
    super.initState();
    _loadVans();
  }

  Future<void> _switchVanDatabase(int vanId) async {
    try {
      String vanDbName = 'van_$vanId.db';
      await dbHelper.openDatabaseForVan(vanDbName);
      await _loadStudents();
    } catch (e) {
      _showToast('Failed to switch database');
      if (kDebugMode) {
        print('Error switching database: $e');
      }
    }
  }

  Future<void> _loadVans() async {
    try {
      List<Map<String, dynamic>> vansFromDb = await dbHelper.getVans();
      setState(() {
        vans = vansFromDb;
        if (vans.isNotEmpty) {
          selectedVanId = vans.first['id'] as int?;
          _loadStudents();
        } else {
          selectedVanId = null;
          students = [];
          filteredStudents = [];
        }
      });
    } catch (e) {
      _showToast('Failed to load vans');
      if (kDebugMode) {
        print('Error loading vans: $e');
      }
    }
  }

  Future<void> _loadStudents() async {
    if (selectedVanId == null) return;

    try {
      await _switchVanDatabase(selectedVanId!);
      List<Map<String, dynamic>> studentsFromDb =
          await dbHelper.getStudents(selectedVanId!);
      setState(() {
        students = studentsFromDb;
        filteredStudents = students;
      });
    } catch (e) {
      _showToast('Failed to load students');
      if (kDebugMode) {
        print('Error loading students: $e');
      }
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(msg: message);
  }

  void _showAddVanDialog() {
    TextEditingController driverController = TextEditingController();
    TextEditingController modelController = TextEditingController();
    TextEditingController seatCountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Van'),
          titleTextStyle: const TextStyle(color: Color(0xFF003366)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(driverController, 'Driver Name'),
              _buildTextField(modelController, 'Van Model'),
              _buildTextField(seatCountController, 'Seat Count',
                  keyboardType: TextInputType.number),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                Navigator.of(context).pop();
                _handleAddVan(
                  driverController.text,
                  modelController.text,
                  int.tryParse(seatCountController.text) ?? 0,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleAddVan(
      String driverName, String vanModel, int seatCount) async {
    if (driverName.isEmpty || vanModel.isEmpty || seatCount <= 0) {
      _showToast('Invalid input for van');
      return;
    }

    try {
      int vanId = await dbHelper.addVan(driverName, vanModel, seatCount);
      await _loadVans();
      setState(() {
        selectedVanId = vanId;
      });
      _showToast('Van added');
    } catch (e) {
      _showToast('Failed to add van');
      if (kDebugMode) {
        print('Error adding van: $e');
      }
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String labelText, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
    );
  }

  void _showAddStudentDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController addressController = TextEditingController();
    TextEditingController phoneController = TextEditingController();
    TextEditingController dobController = TextEditingController();
    TextEditingController schoolController = TextEditingController();
    TextEditingController gradeController = TextEditingController();
    TextEditingController creditAmountController = TextEditingController();
    TextEditingController depositedAmountController = TextEditingController();

    bool isMale = true;
    String shift = 'morning';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Student'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(nameController, 'Name'),
                  _buildGenderRadios(isMale,
                      (value) => setState(() => isMale = value ?? true)),
                  _buildTextField(addressController, 'Address'),
                  _buildTextField(phoneController, 'Phone'),
                  _buildTextField(dobController, 'Date of Birth'),
                  _buildShiftDropdown(shift,
                      (value) => setState(() => shift = value ?? 'morning')),
                  _buildTextField(schoolController, 'School'),
                  _buildTextField(gradeController, 'Grade'),
                  _buildTextField(creditAmountController, 'Credit Amount',
                      keyboardType: TextInputType.number),
                  _buildTextField(depositedAmountController, 'Deposited Amount',
                      keyboardType: TextInputType.number),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                Navigator.of(context).pop();
                _handleAddStudent(
                  nameController.text,
                  isMale,
                  addressController.text,
                  phoneController.text,
                  dobController.text,
                  shift,
                  schoolController.text,
                  gradeController.text,
                  (double.tryParse(creditAmountController.text) ?? 0),
                  (double.tryParse(depositedAmountController.text) ?? 0),
                );
              },
            ),
          ],
        );
      },
    );
  }

  String capitalize(String text) {
    if (text.isEmpty) {
      return text;
    }
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  Widget _buildShiftDropdown(String shift, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: shift,
        decoration: InputDecoration(
          labelText: 'Shift',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        items: ['morning', 'afternoon', 'night']
            .map((shift) => DropdownMenuItem(
                  value: shift,
                  child: Text(capitalize(shift)),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildGenderRadios(bool isMale, ValueChanged<bool?> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: isMale,
              onChanged: onChanged,
            ),
            const Text('Male'),
          ],
        ),
        Row(
          children: [
            Radio<bool>(
              value: false,
              groupValue: isMale,
              onChanged: onChanged,
            ),
            const Text('Female'),
          ],
        ),
      ],
    );
  }

  Future<void> _handleAddStudent(
    String name,
    bool isMale,
    String address,
    String phone,
    String dob,
    String shift,
    String school,
    String grade,
    double creditAmount,
    double depositedAmount,
  ) async {
    if (name.isEmpty ||
        address.isEmpty ||
        phone.isEmpty ||
        dob.isEmpty ||
        school.isEmpty ||
        grade.isEmpty ||
        creditAmount <= 0 ||
        depositedAmount < 0) {
      _showToast('Invalid input for student');
      return;
    }

    try {
      int totalPasses = (depositedAmount / creditAmount).floor();

      await dbHelper.addStudent(
        name,
        isMale,
        address,
        phone,
        dob,
        shift,
        school,
        grade,
        creditAmount,
        depositedAmount,
        totalPasses,
        selectedVanId!,
      );
      await _loadStudents();
      _showToast('Student added');
    } catch (e) {
      _showToast('Failed to add student');
      if (kDebugMode) {
        print('Error adding student: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddStudentDialog,
          ),
          IconButton(
            icon: const Icon(Icons.add_circle),
            onPressed: _showAddVanDialog,
          ),
        ],
      ),
      body: vans.isEmpty
          ? const Center(child: Text('No vans available'))
          : Column(
              children: [
                _buildVanDropdown(),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredStudents.length,
                    itemBuilder: (context, index) {
                      final student = filteredStudents[index];
                      return ListTile(
                        title: Text(student['name'] ?? 'No Name'),
                        subtitle: Text(student['address'] ?? 'No Address'),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            // Implement student editing functionality
                          },
                        ),
                        onTap: () {
                          // Implement student detail view
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildVanDropdown() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButton<int>(
        value: selectedVanId,
        hint: const Text('Select Van'),
        items: vans.map((van) {
          return DropdownMenuItem<int>(
            value: van['id'] as int?,
            child: Text(van['driverName'] ?? 'Unknown Van'),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedVanId = value;
            _loadStudents();
          });
        },
      ),
    );
  }
}
