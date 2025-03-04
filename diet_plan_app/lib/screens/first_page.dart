
import 'package:diet_plan_app/auth/log_in_form.dart';
import 'package:flutter/material.dart';

  
  class FirstPage extends StatelessWidget{
  const FirstPage({super.key});

void _showLoginPage(BuildContext context){
  Navigator.of(context).push(
   MaterialPageRoute(
    builder: (ctx) => const LogInPage()) );
}

    
  @override
  Widget build(context){
    
  
    return Scaffold(
      
      body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white,
                Colors.white,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),

          child:  Center(
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                    'assets/images/diet.png', // Image asset
                    width: 300,
                    
                  ),
            
            
                    const SizedBox(height: 30),
                   ElevatedButton.icon(
                
              onPressed: () {
                _showLoginPage(context);
              }, 
               
               label: const Text('Get Started',
              style:  TextStyle(color: Colors.white,
              fontSize: 25)),
                    
               icon: const Icon(Icons.arrow_right_alt,
               color: Colors.white,
               size: 50,),
               style: ElevatedButton.styleFrom(backgroundColor: Colors.green,
               fixedSize:const Size.fromHeight(50),),
               ),
                    
            
            ],
            
               
               
                
                     
                    
                    ),
          ),
        ),
      
      
    );
  }

  }

 



  

