import 'dart:developer';
import 'package:http/http.dart';

class RecipeService{
  Future getData(String url) async{
     final response = await get(Uri.parse(url));
     if(response.statusCode == 200){
        return response.body;
     }
     else {
      log(response.body);
     }
  }
}