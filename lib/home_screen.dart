import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _response = "";
  bool _isLoading = false;

  Future<String> getResponseFromAPI(String search) async {
    try {
      String apiKey = "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";
      var url = Uri.https("api.openai.com", "/v1/completions");

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      };

      Map<String, dynamic> body = {
        "model": 'text-davinci-003',
        "prompt": search,
        "max_tokens": 2000,
      };

      var response =
      await http.post(url, headers: headers, body: jsonEncode(body));
      if (response.statusCode == 200) {
        var responseJson = jsonDecode(response.body);
        return responseJson["choices"][0]["text"];
      } else {
        throw Exception("Failed to get response from API");
      }
    } catch (e) {
      print("Caught exception: $e");
      return "";
    }
  }

  void _getResponse() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String response =
      await getResponseFromAPI(_searchController.text.toString());
      setState(() {
        _response = response;
      });
    } catch (e) {
      _response = e.toString();
    }
    setState(() {
      _isLoading = false;
    });
  }


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.purple.shade50, Colors.purple.shade400])
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.purple,
          centerTitle: true,

          title: const Text(
            "Chatbot",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: EdgeInsets.all(screenHeight / 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Form(
                  key: _formKey ,
                    child:Column(
                      children: [
                        TextFormField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'your question...',
                          ),
                          validator: (val)
                          {
                            if(val!.isEmpty){
                              return 'Please enter your question';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: screenHeight / 30),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.purple)
                          ),
                              onPressed:(){
                                if(_formKey.currentState!.validate())
                                {
                                  _getResponse();
                              }
                              },

                              child: const Text(
                              "Get Response",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold
                              )
                          ),
                        ),
                        SizedBox(height: screenHeight / 30),
                      ],
                    )

                ),

                Card(
                  elevation: 10,
                  color: Colors.purple.shade100,
                  child: _response.isNotEmpty
                      ? Padding(
                        padding: EdgeInsets.only(
                      top: 10,
                      left: screenHeight / 50,
                      right: screenHeight / 50,
                      bottom: screenHeight / 20,
                      ),
                         child: Text(_response),
                  )
                      : Container(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}