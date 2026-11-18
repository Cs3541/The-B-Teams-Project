import 'package:flutter/material.dart';
import 'app_top_bar.dart';
import '../presenters/sleep_calc_presenter.dart';


class SleepCalcScreen extends StatefulWidget {
  const SleepCalcScreen({super.key});

  @override
  State<SleepCalcScreen> createState() => _SleepCalcScreenState();
}

class _SleepCalcScreenState extends State<SleepCalcScreen> {
  final SleepCalcPresenter _presenter = SleepCalcPresenter();

  int _age = -1;
  bool _yearOrMonth = true;
  bool _sleepOrWakeUp = true;
  double _hours = 0;
  double _minutes = 0;
  bool _isAM = true;

  String resultTextString() {
    String infoText = '';
    String calculatedTime = _presenter.calculateSleepDuration(_age, _yearOrMonth, _sleepOrWakeUp, _hours, _minutes, _isAM);
    
    //Faulty input catcher
    if (_age < 0){
      return "Error: Please enter an age at least equal to or greater than 0";
    }
    if (_hours < 0 || _hours > 12){
      return "Error: Please enter numbers between 0 and 12 for hours ";
    }
    if (_minutes < 0 || _minutes > 60){
      return "Error: Please enter numbers between 0 and 60 for minutes ";
    }

    // Wake up time message
    if (!_sleepOrWakeUp){
      infoText = 'Calculated Wake Up Time: ';
    }
    // bedtime message
    else if (_sleepOrWakeUp){
      infoText = 'Calculated Bedtime: ';
    }
    
    return infoText + calculatedTime;
  }


  Future<void> _showCalcDialog() async {
    final formKey = GlobalKey<FormState>();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sleep Calculation Result'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  resultTextString(),
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(
        title: 'Sleep Calculator',
        titleStyle: TextStyle(
          fontSize: 24,
          color: Colors.white60,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            //Calculator section 
            Container(
              padding: EdgeInsets.all(10),
              width: 370,
              decoration: BoxDecoration(            
              borderRadius: BorderRadius.circular(15), 
              border: Border.all(color: Colors.black, width: 3),
              ),
              child: 
                Column(
                  children: [
                    Text(
                      'Sleep Calculator',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  //padding between title and age
                  SizedBox(height: 10),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                      width: 120,
                        child:
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Enter age',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          style: TextStyle(fontSize: 16),
                          onChanged: (value) {
                            setState(() {
                              _age = int.tryParse(value) ?? -1;
                            });
                          },
                        ),
                      ),

                      SizedBox(
                      width: 113, // Set your desired width here
                      child: DropdownButtonFormField<bool>(
                          initialValue: _yearOrMonth==true,
                          items: const [
                            DropdownMenuItem(
                              value: true,
                              child: Text('Years Old'),
                            ),

                            DropdownMenuItem(
                              value: false,
                              child: Text('Months Old'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _yearOrMonth = value ?? false;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    width: 200,
                      child: DropdownButtonFormField<bool>(
                        initialValue: _sleepOrWakeUp==true,
                        items: const [
                          DropdownMenuItem(
                            value: true,
                            child: Text('Enter Time to wake up'),
                          ),

                          DropdownMenuItem(
                            value: false,
                            child: Text('Enter Time to go to bed'),
                          ),
                        ],
                      onChanged: (value) {
                        setState(() {
                          _sleepOrWakeUp = value ?? false;
                        });
                      },
                    ),
                  ),

                  //padding between two rows
                  SizedBox(height: 5),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                      width: 60,
                        child:
                        TextField(
                          decoration: InputDecoration(
                            hintText: '00',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          style: TextStyle(fontSize: 16),
                          onChanged: (value) {
                            setState(() {
                              _hours = double.tryParse(value) ?? 0.0;
                            });
                          },

                        ),
                      ),
                      Text(
                        ':',
                        style: TextStyle(fontSize: 30),
                      ),
                      SizedBox(
                      width: 60,
                        child:
                        TextField(
                          decoration: InputDecoration(
                            hintText: '00',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          style: TextStyle(fontSize: 16),
                          onChanged: (value) {
                            setState(() {
                              _minutes = double.tryParse(value) ?? 0.0;
                            });
                          },

                        ),
                      ),
                      SizedBox(
                      width: 90,
                      child: DropdownButtonFormField<bool>(
                          initialValue: _isAM==true,
                          items: const [
                            DropdownMenuItem(
                              value: true,
                              child: Text('AM'),
                            ),

                            DropdownMenuItem(
                              value: false,
                              child: Text('PM'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _isAM = value ?? false;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showCalcDialog();
                    },
                    icon: const Icon(Icons.calculate),
                    label: const Text('Calculate Sleep'),
                  ),
                ]
              )
        ),
            
        //spacing between the calculator and the table
        SizedBox(height: 20),

        //Table of the CDC's reccommended sleep time by age group
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1),
          ),
          child:
            Column(
              children: [
                Table(
                  border: TableBorder.all(),
                  columnWidths: const <int, TableColumnWidth>{
                    0: IntrinsicColumnWidth(),
                    1: FlexColumnWidth(),
                  },
                  defaultVerticalAlignment: .middle,
                  children: <TableRow>[
                    TableRow(
                      decoration: const BoxDecoration(color: Colors.grey),
                      children: <Widget>[
                        Text('Age Group', style: TextStyle(fontSize: 16)),
                        Text('Age', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
                        Text('Sleep Recommended Daily', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    TableRow(
                      children: <Widget>[
                        Text('Newborn', style: TextStyle(fontSize: 16)),
                        Text('0-3 months', style: TextStyle(fontSize: 16)),
                        Text('14-17 hours', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    TableRow(
                      children: <Widget>[
                        Text('Infant', style: TextStyle(fontSize: 16)),
                        Text('4-12 months', style: TextStyle(fontSize: 16)),
                        Text('12-16 hours', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    TableRow(
                      children: <Widget>[
                        Text('Toddler', style: TextStyle(fontSize: 16)),
                        Text('1-2 years', style: TextStyle(fontSize: 16)),
                        Text('11-14 hours', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    TableRow(
                      children: <Widget>[
                        Text('Preschool', style: TextStyle(fontSize: 16)),
                        Text('3-5 years', style: TextStyle(fontSize: 16)),
                        Text('10-13 hours', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    TableRow(
                      children: <Widget>[
                        Text('School Age ', style: TextStyle(fontSize: 16)),
                        Text('6-12 years', style: TextStyle(fontSize: 16)),
                        Text('9-12 hours', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    TableRow(
                      children: <Widget>[
                        Text('Teen', style: TextStyle(fontSize: 16)),
                        Text('13-17 years', style: TextStyle(fontSize: 16)),
                        Text('8-10 hours', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    TableRow(
                      children: <Widget>[
                        Text('Adult', style: TextStyle(fontSize: 16)),
                        Text('18-60 years', style: TextStyle(fontSize: 16)),
                        Text('7+ hours', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    TableRow(
                      children: <Widget>[
                        Text('Adult', style: TextStyle(fontSize: 16)),
                        Text('61-64 years', style: TextStyle(fontSize: 16)),
                        Text('7-9 hours', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    TableRow(
                      children: <Widget>[
                        Text('Adult', style: TextStyle(fontSize: 16)),
                        Text('65+ years', style: TextStyle(fontSize: 16)),
                        Text('7-8 hours', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ],
                ),
                Text(
                  'Source: The CDC, https://www.cdc.gov/sleep/about/index.html',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
                ]
              )
            )
          ],
        ),
      ),
    );
  }
}