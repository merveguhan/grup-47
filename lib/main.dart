import 'package:flutter/material.dart';
import 'dart:async';

// --- MODELLER ---
class User {
  final int id;
  final String name;
  final int age;
  User({required this.id, required this.name, required this.age});
}

class Medicine {
  final int id;
  final String name;
  final String content;
  final List<String> days;
  final List<String> times;
  final int userId;
  Medicine({
    required this.id,
    required this.name,
    required this.content,
    required this.days,
    required this.times,
    required this.userId,
  });
}

enum ReminderStatus { taken, skipped, snoozed }

class ReminderLog {
  final DateTime dateTime;
  final String medicineName;
  final String dosage;
  final ReminderStatus status;

  ReminderLog({
    required this.dateTime,
    required this.medicineName,
    required this.dosage,
    required this.status,
  });
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  User? _activeUser;
  List<User> _users = [];
  bool _showSplash = true;
  DateTime? _treatmentEndDate;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        _showSplash = false;
      });
    });
  }

  void _onUserSelected(User user) {
    setState(() {
      _activeUser = user;
    });
  }

  void _onUserCreated(User user) {
    setState(() {
      _users.add(user);
      _activeUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'İlaç Takip',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      home: _showSplash
          ? const SplashScreen()
          : _activeUser == null
              ? ProfileScreen(
                  users: _users,
                  onUserSelected: _onUserSelected,
                  onUserCreated: _onUserCreated,
                )
              : HomeScreen(activeUser: _activeUser!),
      routes: {
        '/profile': (_) => ProfileScreen(
              users: _users,
              onUserSelected: _onUserSelected,
              onUserCreated: _onUserCreated,
            ),
        '/medicine_edit': (_) => MedicineEditScreen(
              onTreatmentEndDateChanged: (date) {
                setState(() {
                  _treatmentEndDate = date;
                });
              },
            ),
        '/notification_settings': (_) => NotificationSettingsScreen(
              treatmentEndDate: _treatmentEndDate,
            ),
        '/reminder_history': (_) => const ReminderHistoryScreen(),
        '/dashboard': (_) => DashboardScreen(
              userName: _activeUser?.name ?? 'Kullanıcı',
              totalToday: 3,
              takenToday: 2,
              skippedToday: 1,
              nextMedicine: '21:00 - Parol',
              motivationMessage: 'Harika gidiyorsun! Sağlığın için devam et!',
              recentLogs: [], // Hatırlatma geçmişinizden alınabilir
            ),
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Arka plan fotoğrafı
          Image.asset(
            'assets/splash_bg.jpg.png',
            fit: BoxFit.cover,
          ),
          // Gri yarı saydam katman
          Container(
            color: Colors.grey.withOpacity(0.5),
          ),
          // Logo ve yazı
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(32),
                  child: Icon(
                    Icons.medication,
                    size: 72,
                    color: Colors.blue[700],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'MedHelper',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- PROFİL EKRANI ---
class ProfileScreen extends StatefulWidget {
  final List<User> users;
  final void Function(User) onUserSelected;
  final void Function(User) onUserCreated;
  const ProfileScreen({Key? key, required this.users, required this.onUserSelected, required this.onUserCreated}) : super(key: key);
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _showAddUserDialog() {
    final nameController = TextEditingController();
    final surnameController = TextEditingController();
    final ageController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Kullanıcı Oluştur', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'İsim')),
                TextField(controller: surnameController, decoration: const InputDecoration(labelText: 'Soyisim')),
                TextField(controller: ageController, decoration: const InputDecoration(labelText: 'Yaş'), keyboardType: TextInputType.number),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('İptal')),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final name = nameController.text.trim();
                        final surname = surnameController.text.trim();
                        final age = int.tryParse(ageController.text.trim()) ?? 0;
                        if (name.isNotEmpty && surname.isNotEmpty && age > 0) {
                          final user = User(id: DateTime.now().millisecondsSinceEpoch, name: '$name $surname', age: age);
                          widget.onUserCreated(user);
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('Oluştur'),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Kayıtlı Kullanıcılar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ElevatedButton(
                  onPressed: _showAddUserDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  child: const Text('Kullanıcı Oluştur'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.users.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'Kayıtlı kullanıcı yok. \nLütfen yeni kullanıcı oluşturun.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ...widget.users.map((user) => Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ListTile(
                    title: Text(user.name, style: const TextStyle(fontSize: 16)),
                    subtitle: Text('Yaş: ${user.age}', style: const TextStyle(color: Colors.grey)),
                    onTap: () {
                      widget.onUserSelected(user);
                      Navigator.of(context).pop();
                    },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    tileColor: Colors.blue.shade50,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

// --- ANASAYFA ---
class HomeScreen extends StatelessWidget {
  final User activeUser;
  const HomeScreen({Key? key, required this.activeUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anasayfa'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 12.0),
            child: Text(
              'Kullanıcı: ${activeUser.name}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //const Text('Bugünün ilaçlarını görmek için tıklayın:', style: TextStyle(fontSize: 16)),
            //const SizedBox(height: 24),
            _HomeButton(text: 'Genel Durum', onTap: () => Navigator.pushNamed(context, '/dashboard')),
            const SizedBox(height: 32),
            _HomeButton(text: 'İlaç Listesi ve Takip', onTap: () => Navigator.pushNamed(context, '/medicine_edit')),
            const SizedBox(height: 12),
            _HomeButton(text: 'Bildirim Ayarları', onTap: () => Navigator.pushNamed(context, '/notification_settings')),
            const SizedBox(height: 12),
            _HomeButton(text: 'Hatırlatma Geçmişi', onTap: () => Navigator.pushNamed(context, '/reminder_history')),
            const SizedBox(height: 12),

            // Kullanıcı adı artık AppBar'da, burası kaldırıldı.
          ],
        ),
      ),
    );
  }
}

class _HomeButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _HomeButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          side: const BorderSide(color: Colors.deepPurple),
          foregroundColor: Colors.deepPurple,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text(text, style: const TextStyle(fontSize: 15)),
      ),
    );
  }
}

// --- İLAÇ EKLE/DÜZENLE EKRANI ---
class MedicineEditScreen extends StatefulWidget {
  final void Function(DateTime?)? onTreatmentEndDateChanged;
  const MedicineEditScreen({Key? key, this.onTreatmentEndDateChanged}) : super(key: key);

  @override
  State<MedicineEditScreen> createState() => _MedicineEditScreenState();
}

class _MedicineEditScreenState extends State<MedicineEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _medicineNameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final List<String> medicineSuggestions = [
    'Parol', 'Aferin', 'Augmentin', 'Dolorex', 'Nurofen', 'Minoset', 'Vermidon'
  ];
  final List<String> units = ['mg', 'ml', 'tablet', 'kapsül', 'sprey'];
  late String selectedUnit;

  DateTime? startDate;
  DateTime? endDate;
  String treatmentType = 'Sürekli kullanım';
  final List<String> treatmentTypes = ['Sürekli kullanım', 'Belirli bir süre'];
  final TextEditingController durationController = TextEditingController();
  final List<String> durationUnits = ['gün', 'hafta', 'ay'];
  String selectedDurationUnit = 'gün';

  List<String> selectedDays = [];
  bool isPRN = false;
  String selectedMealRelation = 'Aç karnına';

  List<TimeOfDay> selectedTimes = [];

  final List<String> forms = ['Tablet', 'Kapsül', 'Şurup', 'Damla', 'Merhem', 'İğne'];
  String selectedForm = 'Tablet';

  Future<void> pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTimes.add(picked);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    selectedUnit = units[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('İlaç Ekle/Düzenle')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'İlaç Adı *',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text == '') {
                      return const Iterable<String>.empty();
                    }
                    return medicineSuggestions.where((String option) {
                      return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                    _medicineNameController.text = controller.text;
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'İlaç adını girin',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'İlaç adı zorunludur';
                        }
                        return null;
                      },
                    );
                  },
                  onSelected: (String selection) {
                    _medicineNameController.text = selection;
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Dozaj Miktarı',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _dosageController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Miktar',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Dozaj miktarı girin';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Geçerli bir sayı girin';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: StatefulBuilder(
                        builder: (context, setState) {
                          return DropdownButtonFormField<String>(
                            value: selectedUnit,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            items: units
                                .map((unit) => DropdownMenuItem(
                                      value: unit,
                                      child: Text(unit),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  selectedUnit = value;
                                });
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'İlaç Formu',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: forms.map((form) {
                    return ChoiceChip(
                      label: Text(form),
                      selected: selectedForm == form,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            selectedForm = form;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Alınma Sıklığı / Zamanlaması',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                StatefulBuilder(
                  builder: (context, setState) {
                    // Sıklık türü seçimi
                    final List<String> frequencyTypes = [
                      //'Günde kaç defa',
                      'Belirli saatlerde',
                      'Her X saatte bir',
                      'Haftanın günleri',
                      'İhtiyaç halinde (PRN)'
                    ];
                    String selectedFrequency = frequencyTypes[0];

                    // Günde X defa
                    final TextEditingController timesPerDayController = TextEditingController();

                    // Her X saatte bir
                    final TextEditingController everyXHourController = TextEditingController();

                    // Belirli saatler
                    List<TimeOfDay> selectedTimes = [];

                    // Haftanın günleri
                    final List<String> weekDays = [
                      'Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'
                    ];
                    Set<String> selectedDays = {};

                    // PRN
                    bool isPRN = false;

                    // Yemek zamanı ilişkisi
                    final List<String> mealRelations = [
                      'Aç karnına', 'Tok karnına', 'Yemekle birlikte', 'Fark etmez'
                    ];
                    String selectedMealRelation = mealRelations[0];

                    Future<void> pickTime() async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedTimes.add(picked);
                        });
                      }
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
                          value: selectedFrequency,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Sıklık Seçimi',
                          ),
                          items: frequencyTypes
                              .map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                selectedFrequency = val;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        if (selectedFrequency == 'Günde X defa')
                          TextFormField(
                            controller: timesPerDayController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Günde kaç defa?',
                            ),
                          ),
                        if (selectedFrequency == 'Her X saatte bir')
                          TextFormField(
                            controller: everyXHourController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Kaç saatte bir?',
                            ),
                          ),
                        if (selectedFrequency == 'Belirli saatlerde')
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                children: selectedTimes
                                    .map((t) => Chip(
                                          label: Text(t.format(context)),
                                          onDeleted: () {
                                            setState(() {
                                              selectedTimes.remove(t);
                                            });
                                          },
                                        ))
                                    .toList(),
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                onPressed: pickTime,
                                icon: const Icon(Icons.access_time),
                                label: const Text('Saat Ekle'),
                              ),
                            ],
                          ),
                        if (selectedFrequency == 'Haftanın günleri')
                          Wrap(
                            spacing: 8,
                            children: weekDays.map((day) {
                              return ChoiceChip(
                                label: Text(day),
                                selected: selectedDays.contains(day),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      selectedDays.add(day);
                                    } else {
                                      selectedDays.remove(day);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        if (selectedFrequency == 'İhtiyaç halinde (PRN)')
                          CheckboxListTile(
                            value: isPRN,
                            onChanged: (val) {
                              setState(() {
                                isPRN = val ?? false;
                              });
                            },
                            title: const Text('İhtiyaç halinde kullanılıyor'),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedMealRelation,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Kullanım Şekli',
                          ),
                          items: mealRelations
                              .map((relation) => DropdownMenuItem(
                                    value: relation,
                                    child: Text(relation),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                selectedMealRelation = val;
                              });
                            }
                          },
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Tedavi Süresi / Başlangıç-Bitiş Tarihleri',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                // Tedavi Türü Seçimi
                Row(
                  children: [
                    Radio<String>(
                      value: 'Sürekli kullanım',
                      groupValue: treatmentType,
                      onChanged: (val) {
                        setState(() {
                          treatmentType = val!;
                        });
                      },
                    ),
                    const Text('Sürekli kullanım'),
                    const SizedBox(width: 16),
                    Radio<String>(
                      value: 'Belirli bir süre',
                      groupValue: treatmentType,
                      onChanged: (val) {
                        setState(() {
                          treatmentType = val!;
                        });
                      },
                    ),
                    const Text('Belirli bir süre'),
                  ],
                ),
                // Eğer "Belirli bir süre" seçiliyse, Başlangıç ve Bitiş Tarihi göster
                if (treatmentType == 'Belirli bir süre') ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Başlangıç Tarihi: '),
                      Text(
                        startDate != null
                            ? "${startDate!.day}.${startDate!.month}.${startDate!.year}"
                            : "Seçilmedi",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: startDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              startDate = picked;
                            });
                          }
                        },
                        child: const Text('Tarih Seç'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Bitiş Tarihi: '),
                      Text(
                        endDate != null
                            ? "${endDate!.day}.${endDate!.month}.${endDate!.year}"
                            : "Seçilmedi",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: endDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              endDate = picked;
                            });
                            if (widget.onTreatmentEndDateChanged != null) {
                              widget.onTreatmentEndDateChanged!(picked);
                            }
                          }
                        },
                        child: const Text('Tarih Seç'),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Kaydetme işlemi burada yapılacak
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('İlaç kaydedildi!')),
                        );
                      }
                    },
                    child: const Text('Kaydet'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- BİLDİRİM AYARLARI EKRANI ---
class NotificationSettingsScreen extends StatefulWidget {
  final DateTime? treatmentEndDate;
  const NotificationSettingsScreen({Key? key, this.treatmentEndDate}) : super(key: key);
  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}
class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool notificationsEnabled = true;
  TimeOfDay notificationTime = const TimeOfDay(hour: 9, minute: 0);
  String notificationSound = 'Varsayılan';
  final List<String> soundOptions = ['Varsayılan', 'Ses 1', 'Ses 2'];
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: notificationTime,
    );
    if (picked != null) {
      setState(() {
        notificationTime = picked;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirim Ayarları'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Bildirimleri Aç', style: TextStyle(fontSize: 16)),
                Switch(
                  value: notificationsEnabled,
                  activeColor: Colors.deepPurple,
                  onChanged: (val) => setState(() => notificationsEnabled = val),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Bildirim Saati', style: TextStyle(fontSize: 16)),
                Row(
                  children: [
                    Text(notificationTime.format(context), style: const TextStyle(fontSize: 16)),
                    IconButton(icon: const Icon(Icons.access_time), onPressed: _pickTime),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Bildirim Sesi', style: TextStyle(fontSize: 16)),
                DropdownButton<String>(
                  value: notificationSound,
                  items: soundOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => notificationSound = val);
                  },
                ),
              ],
            ),
            if (widget.treatmentEndDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  'Tedavi Bitiş Tarihi: ${widget.treatmentEndDate!.day}.${widget.treatmentEndDate!.month}.${widget.treatmentEndDate!.year}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            if (widget.treatmentEndDate != null &&
                DateTime.now().year == widget.treatmentEndDate!.year &&
                DateTime.now().month == widget.treatmentEndDate!.month &&
                DateTime.now().day == widget.treatmentEndDate!.day)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Bugün tedavi bitiş günü! Lütfen doktorunuza danışın.',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            const Spacer(),
            Center(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.deepPurple,
                  side: const BorderSide(color: Colors.deepPurple),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                ),
                child: const Text('Kaydet', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- HATIRLATMA GEÇMİŞİ EKRANI ---
class ReminderHistoryScreen extends StatefulWidget {
  const ReminderHistoryScreen({Key? key}) : super(key: key);
  @override
  State<ReminderHistoryScreen> createState() => _ReminderHistoryScreenState();
}
class _ReminderHistoryScreenState extends State<ReminderHistoryScreen> {
  final List<ReminderLog> reminderLogs = [
    ReminderLog(
      dateTime: DateTime(2024, 6, 1, 9, 0),
      medicineName: 'Parol',
      dosage: '500 mg',
      status: ReminderStatus.taken,
    ),
    ReminderLog(
      dateTime: DateTime(2024, 6, 1, 13, 0),
      medicineName: 'Aferin',
      dosage: '1 tablet',
      status: ReminderStatus.skipped,
    ),
    ReminderLog(
      dateTime: DateTime(2024, 6, 1, 21, 0),
      medicineName: 'Dolorex',
      dosage: '50 mg',
      status: ReminderStatus.snoozed,
    ),
  ];
  final Set<String> expandedDates = {};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hatırlatma Geçmişi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView.builder(
        itemCount: reminderLogs.length,
        itemBuilder: (context, index) {
          final log = reminderLogs[index];
          IconData icon;
          Color color;
          String statusText;
          switch (log.status) {
            case ReminderStatus.taken:
              icon = Icons.check_circle;
              color = Colors.green;
              statusText = 'Alındı';
              break;
            case ReminderStatus.skipped:
              icon = Icons.cancel;
              color = Colors.red;
              statusText = 'Atlandı';
              break;
            case ReminderStatus.snoozed:
              icon = Icons.snooze;
              color = Colors.orange;
              statusText = 'Ertelendi';
              break;
          }
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(icon, color: color),
              title: Text(
                '${log.medicineName} - ${log.dosage}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${log.dateTime.day}.${log.dateTime.month}.${log.dateTime.year} '
                '${log.dateTime.hour.toString().padLeft(2, '0')}:${log.dateTime.minute.toString().padLeft(2, '0')}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    statusText,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        reminderLogs.removeAt(index);
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Basit bir dialog ile ekleme
          final result = await showDialog<ReminderLog>(
            context: context,
            builder: (context) {
              final nameController = TextEditingController();
              final dosageController = TextEditingController();
              ReminderStatus status = ReminderStatus.taken;
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: const Text('Yeni Hatırlatma Ekle'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(labelText: 'İlaç Adı'),
                        ),
                        TextField(
                          controller: dosageController,
                          decoration: const InputDecoration(labelText: 'Dozaj'),
                        ),
                        DropdownButton<ReminderStatus>(
                          value: status,
                          items: ReminderStatus.values.map((s) {
                            return DropdownMenuItem(
                              value: s,
                              child: Text(
                                s == ReminderStatus.taken
                                    ? 'Alındı'
                                    : s == ReminderStatus.skipped
                                        ? 'Atlandı'
                                        : 'Ertelendi',
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                status = val;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('İptal'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (nameController.text.isNotEmpty && dosageController.text.isNotEmpty) {
                            Navigator.pop(
                              context,
                              ReminderLog(
                                dateTime: DateTime.now(),
                                medicineName: nameController.text,
                                dosage: dosageController.text,
                                status: status,
                              ),
                            );
                          }
                        },
                        child: const Text('Ekle'),
                      ),
                    ],
                  );
                },
              );
            },
          );
          if (result != null) {
            setState(() {
              reminderLogs.add(result);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// --- DASHBOARD EKRANI ---
class DashboardScreen extends StatelessWidget {
  final String userName;
  final int totalToday;
  final int takenToday;
  final int skippedToday;
  final String nextMedicine;
  final String motivationMessage;
  final List<ReminderLog> recentLogs;

  const DashboardScreen({
    Key? key,
    required this.userName,
    required this.totalToday,
    required this.takenToday,
    required this.skippedToday,
    required this.nextMedicine,
    required this.motivationMessage,
    required this.recentLogs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Genel Durum'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Hoş geldin, $userName!',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _DashboardCard(
              icon: Icons.medical_services,
              iconColor: Colors.blue,
              title: 'Bugünkü İlaçlar',
              content: 'Toplam: $totalToday, Alınan: $takenToday, Atlanan: $skippedToday',
            ),
            const SizedBox(height: 16),
            _DashboardCard(
              icon: Icons.alarm,
              iconColor: Colors.deepOrange,
              title: 'Yaklaşan İlaç',
              content: nextMedicine,
            ),
            const SizedBox(height: 16),
            _DashboardCard(
              icon: Icons.emoji_emotions,
              iconColor: Colors.blueAccent,
              title: 'Motivasyon',
              content: motivationMessage,
              background: Colors.blueAccent.withOpacity(0.1),
            ),
            const SizedBox(height: 16),
            const Text(
              'Son Hatırlatmalar',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            ...recentLogs.take(3).map((log) => ListTile(
                  leading: Icon(
                    log.status == ReminderStatus.taken
                        ? Icons.check_circle
                        : log.status == ReminderStatus.skipped
                            ? Icons.cancel
                            : Icons.snooze,
                    color: log.status == ReminderStatus.taken
                        ? Colors.green
                        : log.status == ReminderStatus.skipped
                            ? Colors.red
                            : Colors.orange,
                  ),
                  title: Text('${log.medicineName} - ${log.dosage}'),
                  subtitle: Text(
                    '${log.dateTime.day}.${log.dateTime.month}.${log.dateTime.year} '
                    '${log.dateTime.hour.toString().padLeft(2, '0')}:${log.dateTime.minute.toString().padLeft(2, '0')}',
                  ),
                  trailing: Text(
                    log.status == ReminderStatus.taken
                        ? 'Alındı'
                        : log.status == ReminderStatus.skipped
                            ? 'Atlandı'
                            : 'Ertelendi',
                    style: TextStyle(
                      color: log.status == ReminderStatus.taken
                          ? Colors.green
                          : log.status == ReminderStatus.skipped
                              ? Colors.red
                              : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
            const SizedBox(height: 16),git fetch origin main
            _DashboardCard(
              icon: Icons.lightbulb,
              iconColor: Colors.purple,
              title: 'Günün Önerisi',
              content: 'İlaçlarınızı her gün aynı saatte almaya özen gösterin!',
              background: Colors.purple.withOpacity(0.08),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String content;
  final Color? background;
  const _DashboardCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.content,
    this.background,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: background ?? Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title.isNotEmpty)
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if (title.isNotEmpty) const SizedBox(height: 4),
                Text(content, style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
