// import 'package:flutter/material.dart';
// import 'package:simple_animations/simple_animations.dart';
// import 'package:spotmies/views/login/loginpage.dart';
// import 'package:spotmies/model/config.dart';

// class OnboardingScreen extends StatefulWidget {
//   @override
//   _OnboardingScreenState createState() => _OnboardingScreenState();
// }

// class _OnboardingScreenState extends State<OnboardingScreen> {
//   List<OnboardingModel> _list = OnboardingModel.list;
//   int page = 0;
//   var _controller = PageController();
//   var showAnimatedContainer = false;
//   @override
//   Widget build(BuildContext context) {
//     SizeConfig().init(context);

//     _controller.addListener(() {
//       setState(() {
//         page = _controller.page.round();
//       });
//     });
//     return Scaffold(
//         backgroundColor: Colors.white,
//         body: Stack(
//           children: [
//             showAnimatedContainer
//                 ? Center(
//                     child: MyAnimatedContainer(),
//                   )
//                 : SafeArea(
//                     child: Column(
//                       children: [
//                         SkipButton(),
//                         Expanded(
//                           child: PageView.builder(
//                               controller: _controller,
//                               itemCount: _list.length,
//                               itemBuilder: (context, index) => MainContent(
//                                     list: _list,
//                                     index: index,
//                                   )),
//                         ),
//                         StepsContainer(
//                           page: page,
//                           list: _list,
//                           controller: _controller,
//                           showAnimatedContainerCallBack: (value) {
//                             setState(() {
//                               showAnimatedContainer = value;
//                               if (value) {
//                                 Future.delayed(Duration(seconds: 1), () {
//                                   Navigator.pushReplacement(
//                                       context,
//                                       MaterialPageRoute(
//                                           builder: (context) => LoginPageScreen()));
//                                 });
//                               }
//                             });
//                           },
//                         ),
//                         SizedBox(
//                           height: SizeConfig.defaultSize * 4,
//                         )
//                       ],
//                     ),
//                   ),
//           ],
//         ));
//   }
// }

// //model

// class OnboardingModel {
//   String image;
//   String text;
//   String title;

//   OnboardingModel({this.image, this.text, this.title});
//   static List<OnboardingModel> list = [
//     OnboardingModel(
//         image: "lib/assets/1.png",
//         title: "take picture",
//         text:
//             "You can do this. Step up to the cutting board, the oven, or the stovetop with full confidence in your abilities"),
//     OnboardingModel(
//         image: "lib/assets/2.png",
//         title: "add location",
//         text:
//             "You can do this. Step up to the cutting board, the oven, or the stovetop with full confidence in your abilities"),
//     OnboardingModel(
//         image: "lib/assets/3.png",
//         title: "get quotes from technicians",
//         text:
//             "You can do this. Step up to the cutting board, the oven, or the stovetop with full confidence in your abilities"),
//     OnboardingModel(
//         image: "lib/assets/4.png",
//         title: "get service instantly",
//         text:
//             "You can do this. Step up to the cutting board, the oven, or the stovetop with full confidence in your abilities")
//   ];
// }

// //animated container
// class MyAnimatedContainer extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return PlayAnimation<double>(
//       tween: Tween(
//         begin: 0.0,
//         end: SizeConfig.orientation == Orientation.portrait
//             ? SizeConfig.screenHeight
//             : SizeConfig.screenWidth,
//       ),
//       duration: Duration(seconds: 1),
//       curve: Curves.easeOut,
//       builder: (context, child, value) {
//         return Container(
//           width: value,
//           height: value,
//           decoration: BoxDecoration(
//               color: Colors.white,
//               image: DecorationImage(
//                   image: AssetImage("images/welcome_image.png"))),
//         );
//       },
//     );
//   }
// }

// //skip button
// class SkipButton extends StatelessWidget {
//   const SkipButton({
//     Key key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.all(SizeConfig.defaultSize),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           InkWell(
//             onTap: () {
//               Navigator.push(context,
//                   MaterialPageRoute(builder: (context) => LoginPageScreen()));
//             },
//             child: Text(
//               'Skip',
//               style: TextStyle(
//                   fontSize: SizeConfig.defaultSize * 1.4, //14
//                   color: Colors.black,
//                   fontWeight: FontWeight.w600),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

// //step container

// class StepsContainer extends StatelessWidget {
//   const StepsContainer(
//       {Key key,
//       @required this.page,
//       @required List<OnboardingModel> list,
//       @required PageController controller,
//       @required this.showAnimatedContainerCallBack})
//       : _list = list,
//         _controller = controller,
//         super(key: key);

//   final int page;
//   final List<OnboardingModel> _list;
//   final PageController _controller;
//   final Function showAnimatedContainerCallBack;
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: SizeConfig.defaultSize * 4.5,
//       height: SizeConfig.defaultSize * 4.5,
//       child: Stack(
//         children: [
//           Container(
//             width: SizeConfig.defaultSize * 4.5,
//             height: SizeConfig.defaultSize * 4.5,
//             child: CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation(Colors.blue[800]),
//                 value: (page + 1) / (_list.length + 1)),
//           ),
//           Center(
//             child: InkWell(
//               onTap: () {
//                 if (page < _list.length && page != _list.length - 1) {
//                   _controller.animateToPage(page + 1,
//                       duration: Duration(microseconds: 500),
//                       curve: Curves.easeInCirc);
//                   showAnimatedContainerCallBack(false);
//                 } else {
//                   showAnimatedContainerCallBack(true);
//                 }
//               },
//               child: Container(
//                 width: SizeConfig.defaultSize * 3.5,
//                 height: SizeConfig.defaultSize * 3.5,
//                 decoration: BoxDecoration(
//                     color: Colors.blue[800],
//                     borderRadius: BorderRadius.all(Radius.circular(100.0))),
//                 child: Icon(
//                   Icons.arrow_forward_ios,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

// //common widget button

// class CommonButtonWidget extends StatelessWidget {
//   final Function onTap;
//   final Color textColor;
//   final Color bgColor;
//   final String title;
//   final double textSizePercentage;
//   final double width;
//   final double height;
//   final Color borderColor;
//   final raduis;
//   CommonButtonWidget(
//       {this.textColor,
//       this.onTap,
//       this.title,
//       this.width,
//       this.height,
//       this.bgColor,
//       this.textSizePercentage,
//       this.borderColor,
//       this.raduis});
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: width,
//       height: height ?? 50,
//       decoration: BoxDecoration(
//           color: bgColor ?? Colors.blue[800],
//           border:
//               Border.all(color: borderColor ?? Colors.transparent, width: 1),
//           borderRadius: raduis ??
//               BorderRadius.only(
//                   bottomLeft: Radius.circular(25),
//                   topLeft: Radius.circular(25))),
//       child: Center(
//         child: CommonText(
//           text: title,
//           textColor: textColor ?? Colors.black,
//           fontWeight: FontWeight.bold,
//           fontSize: textSizePercentage,
//         ),
//       ),
//     );
//   }
// }

// //common text

// class CommonText extends StatelessWidget {
//   final String text;
//   final Color textColor;
//   final double fontSize;
//   final double padding;
//   final FontWeight fontWeight;
//   CommonText(
//       {this.text,
//       this.textColor,
//       this.fontWeight,
//       this.padding,
//       this.fontSize});
//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       text,
//       style: TextStyle(
//           color: textColor ?? Colors.black,
//           fontWeight: fontWeight ?? FontWeight.w400,
//           fontSize: SizeConfig.defaultSize * (fontSize ?? 1.8)),
//     );
//   }
// }

// class MainContent extends StatelessWidget {
//   const MainContent(
//       {Key key, @required List<OnboardingModel> list, @required this.index})
//       : _list = list,
//         super(key: key);

//   final List<OnboardingModel> _list;
//   final index;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.all(SizeConfig.defaultSize * 2),
//       child: Column(
//         children: [
//           Expanded(
//             flex: 3,
//             child: FadeAnimation(
//               0.5,
//               Image.asset(
//                 _list[index].image,
//                 height: SizeConfig.defaultSize * 30,
//                 width: SizeConfig.defaultSize * 30,
//               ),
//             ),
//           ),
//           FadeAnimation(
//             0.9,
//             Text(
//               _list[index].title,
//               style: TextStyle(
//                   color: Colors.black,
//                   fontWeight: FontWeight.w500,
//                   fontSize: SizeConfig.defaultSize * 2.6),
//             ),
//           ),
//           SizedBox(
//             height: SizeConfig.defaultSize,
//           ),
//           FadeAnimation(
//             1.1,
//             Text(
//               _list[index].text,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                   color: Colors.black,
//                   fontWeight: FontWeight.w400,
//                   fontSize: SizeConfig.defaultSize * 1.4),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// //fade animation

// enum AniProps { opacity, translateY }

// class FadeAnimation extends StatelessWidget {
//   final double delay;
//   final Widget child;

//   FadeAnimation(this.delay, this.child, {AssetImage image});

//   @override
//   Widget build(BuildContext context) {
//     final tween = MultiTween<AniProps>()
//       ..add(AniProps.opacity, Tween(begin: 0.0, end: 1.0),
//           Duration(milliseconds: 500))
//       ..add(AniProps.translateY, Tween(begin: -30.0, end: 0.0),
//           Duration(milliseconds: 500), Curves.easeOut);

//     return PlayAnimation<MultiTweenValues<AniProps>>(
//       delay: Duration(milliseconds: (500 * delay).round()),
//       duration: tween.duration,
//       tween: tween,
//       child: child,
//       builder: (context, child, value) => Opacity(
//         opacity: value.get(AniProps.opacity),
//         child: Transform.translate(
//             offset: Offset(0, value.get(AniProps.translateY)), child: child),
//       ),
//     );
//   }
// }
