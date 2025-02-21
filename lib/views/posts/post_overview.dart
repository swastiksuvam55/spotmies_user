import 'dart:convert';
import 'dart:developer';

import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'package:spotmies/controllers/posts_controllers/postOvervire_controller.dart';
import 'package:spotmies/providers/chat_provider.dart';
import 'package:spotmies/providers/getOrdersProvider.dart';
import 'package:spotmies/providers/universal_provider.dart';
import 'package:spotmies/utilities/appConfig.dart';
import 'package:spotmies/utilities/constants.dart';
import 'package:spotmies/utilities/elevatedButtonWidget.dart';
import 'package:spotmies/utilities/media_player.dart';
import 'package:spotmies/utilities/textWidget.dart';
import 'package:spotmies/views/home/ads/page2.dart';
import 'package:spotmies/views/internet_calling/calling.dart';
import 'package:spotmies/views/maps/maps.dart';
import 'package:spotmies/views/reusable_widgets/bottom_options_menu.dart';
import 'package:spotmies/views/reusable_widgets/date_formates%20copy.dart';
import 'package:spotmies/views/reusable_widgets/profile_pic.dart';
import 'package:spotmies/views/reusable_widgets/progress_waiter.dart';
import 'package:spotmies/views/reusable_widgets/queryBS.dart';
import 'package:spotmies/views/reusable_widgets/rating/review_screen.dart';
import 'package:spotmies/views/reusable_widgets/rating/size_provider.dart';
import 'package:spotmies/views/reusable_widgets/text_wid.dart';
import 'package:timelines/timelines.dart';
import 'package:url_launcher/url_launcher.dart';

class PostOverView extends StatefulWidget {
  final String ordId;
  PostOverView({@required this.ordId});
  @override
  _PostOverViewState createState() => _PostOverViewState();
}

class _PostOverViewState extends StateMVC<PostOverView> {
  PostOverViewController _postOverViewController;
  _PostOverViewState() : super(PostOverViewController()) {
    this._postOverViewController = controller;
  }
  ChatProvider chatProvider;
  UniversalProvider up;
  int ordId;
  bool showOrderStatusQuestion = false;
  GetOrdersProvider ordersProvider;
  // _PostOverViewState(this.value);
  // int _currentStep = 0;
  void chatWithPatner(responseData) {
    _postOverViewController.chatWithpatner(responseData);
  }

  @override
  void initState() {
    ordersProvider = Provider.of<GetOrdersProvider>(context, listen: false);
    chatProvider = Provider.of<ChatProvider>(context, listen: false);
    up = Provider.of<UniversalProvider>(context, listen: false);
    up.setCurrentConstants("orders");

    try {
      ordersProvider.getOrderById(widget.ordId)['orderState'] < 9 &&
              ordersProvider.getOrderById(widget.ordId)['orderState'] != 3
          ? showOrderStatusQuestion = true
          : showOrderStatusQuestion = false;

      refresh();
    } catch (e) {}

    super.initState();
  }

  isThisOrderCompleted(state, {String orderID = "123", String money = "0"}) {
    if (state) {
      _postOverViewController.isOrderCompleted(money, orderID);
    }
    showOrderStatusQuestion = false;
    refresh();
  }

  appBarColor(orderState) {
    switch (orderState) {
      case 1:
      case 2:
      case 5:
      case 6:
      case 7:
      case 8:
        return Colors.white;
      case 3:
      case 4:
        return Colors.red;
      case 9:
      case 10:
        return Colors.green;

        break;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeProvider().init(context);
    return Consumer<GetOrdersProvider>(builder: (context, data, child) {
      dynamic d = data.getOrderById(widget.ordId);
      _postOverViewController.orderDetails = d;

      log("ord $d");
      if (d == null)
        return Scaffold(
            body: Center(
                child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.manage_search_rounded,
                color: Colors.grey[700], size: width(context) * 0.3),
            TextWid(
              text: "Unable to Load this order",
              weight: FontWeight.bold,
              size: width(context) * 0.05,
            ),
          ],
        )));
      _postOverViewController.pickedDate =
          DateTime.fromMillisecondsSinceEpoch(d['schedule']);
      _postOverViewController.pickedTime =
          TimeOfDay.fromDateTime(_postOverViewController.pickedDate);

      List<String> images = List.from(d['media']);
      dynamic fullAddress = jsonDecode(d['address']);
      // final coordinates = Coordinates(d['loc'][0], d['loc'][1]);

      return Stack(
        children: [
          Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: appBarColor(d['orderState']),
              toolbarHeight: d['orderState'] < 9 && d['orderState'] != 3
                  ? height(context) * 0.16
                  : height(context) * 0.08,
              elevation: 0,
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: d['orderState'] > 8 ? Colors.white : Colors.grey[900],
                ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    text: up.getServiceNameById(d['job'].runtimeType == String
                        ? int.parse(d['job'])
                        : d['job']),
                    size: width(context) * 0.04,
                    color:
                        d['orderState'] > 8 ? Colors.white : Colors.grey[500],
                    lSpace: 1.5,
                    weight: FontWeight.w600,
                  ),
                  SizedBox(
                    height: height(context) * 0.007,
                  ),
                  Row(
                    children: [
                      Icon(
                        orderStateIcon(ordState: d['orderState']),
                        color: d['orderState'] > 8
                            ? Colors.white
                            : Colors.indigo[900],
                        size: width(context) * 0.035,
                      ),
                      SizedBox(
                        width: width(context) * 0.01,
                      ),
                      Expanded(
                        child: TextWid(
                            text: orderStateString(ordState: d['orderState']),
                            color: d['orderState'] > 8
                                ? Colors.white
                                : Colors.grey[700],
                            flow: TextOverflow.visible,
                            weight: FontWeight.w700,
                            size: width(context) * 0.03),
                      ),
                    ],
                  )
                ],
              ),
              bottom: PreferredSize(
                  child: d['orderState'] < 9 && d['orderState'] != 3
                      ? Container(
                          margin:
                              EdgeInsets.only(bottom: width(context) * 0.01),
                          height: height(context) * 0.06,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButtonWidget(
                                onClick: () {
                                  _postOverViewController
                                      .rescheduleServiceOrCancel(
                                          d['orderState'], d['ordId'],
                                          action: "CANCEL_ORDER");
                                },
                                height: height(context) * 0.05,
                                minWidth: width(context) * 0.4,
                                bgColor: Colors.white,
                                borderSideColor: Colors.grey[200],
                                borderRadius: 10.0,
                                buttonName: 'Cancel',
                                textSize: width(context) * 0.04,
                                leadingIcon: Icon(
                                  Icons.cancel,
                                  color: Colors.grey[900],
                                  size: width(context) * 0.045,
                                ),
                              ),
                              ElevatedButtonWidget(
                                onClick: () async {
                                  await _postOverViewController
                                      .pickDate(context);
                                  await _postOverViewController
                                      .picktime(context);

                                  if (d['schedule'].toString() !=
                                      _postOverViewController
                                          .getDateAndTime()) {
                                    await _postOverViewController
                                        .rescheduleServiceOrCancel(
                                            d['orderState'], d['ordId'],
                                            action: "UPDATE_SCHEDULE");
                                  }
                                },
                                height: height(context) * 0.05,
                                minWidth: width(context) * 0.55,
                                bgColor: Colors.indigo[900],
                                borderSideColor: Colors.grey[200],
                                borderRadius: 10.0,
                                buttonName: 'Re-schedule',
                                textColor: Colors.white,
                                textSize: width(context) * 0.04,
                                trailingIcon: Icon(
                                  Icons.refresh,
                                  color: Colors.white,
                                  size: width(context) * 0.045,
                                ),
                              )
                            ],
                          ),
                        )
                      : Container(),
                  preferredSize: Size.fromHeight(4.0)),
              actions: [
                IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.help,
                      color:
                          d['orderState'] > 8 ? Colors.white : Colors.grey[900],
                    )),
                IconButton(
                    onPressed: () {
                      bottomOptionsMenu(context,
                          options: _postOverViewController.options);
                    },
                    icon: Icon(
                      Icons.more_vert,
                      color:
                          d['orderState'] > 8 ? Colors.white : Colors.grey[900],
                    )),
              ],
            ),
            body: Container(
              height: height(context),
              width: width(context),
              color: Colors.grey[100],
              child: ListView(
                children: [
                  Divider(
                    color: Colors.white,
                  ),
                  Wrap(
                    alignment: WrapAlignment.spaceEvenly,
                    children: [
                      TextWidget(
                        text: orderStateString(ordState: d['orderState']),
                      ),
                      TextWidget(text: "orderId : ${d['ordId']}")
                    ],
                  ),
                  Divider(
                    color: Colors.white,
                  ),
                  Container(
                    //height: height(context) * 0.45,
                    width: width(context),
                    color: Colors.white,
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          padding:
                              EdgeInsets.only(top: 15, left: 15, right: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextWidget(
                                text: 'Service Details :',
                                size: width(context) * 0.055,
                                weight: FontWeight.w600,
                              ),
                              IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                  onPressed: () {},
                                  icon: Icon(Icons.edit))
                            ],
                          ),
                        ),
                        serviceDetailsListTile(
                          width(context),
                          height(context),
                          'Issue/Problem',
                          Icons.settings,
                          d['problem'],
                        ),
                        serviceDetailsListTile(
                          width(context),
                          height(context),
                          'Schedule',
                          Icons.schedule,
                          getDate(d['schedule']) + "-" + getTime(d['schedule']),
                        ),
                        Stack(
                          children: [
                            serviceDetailsListTile(
                                width(context),
                                height(context),
                                'Location',
                                Icons.location_on,
                                fullAddress['addressLine'] ??
                                    "Unable to get service address"),
                            Positioned(
                                right: width(context) * 0.02,
                                top: height(context) * 0.02,
                                child: IconButton(
                                    onPressed: () {
                                      var coordiantes = {
                                        "latitude": double.parse(
                                            fullAddress['latitude']),
                                        "logitude": double.parse(
                                            fullAddress['logitude'])
                                      };
                                      // log(fullAddress['latitude']);

                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) => Maps(
                                                    coordinates: coordiantes,
                                                    isSearch: false,
                                                    isNavigate: false,
                                                    actionLabel:
                                                        "Update Location",
                                                    onSave: (cords, address) {
                                                      log("$cords $address");
                                                      Navigator.pop(context);
                                                      _postOverViewController
                                                          .rescheduleServiceOrCancel(
                                                              d['orderState'],
                                                              d['ordId'],
                                                              action:
                                                                  "UPDATE_LOCATION",
                                                              updatedAddress:
                                                                  address,
                                                              updatedCoordinate:
                                                                  cords);
                                                    },
                                                  )));
                                    },
                                    icon: Icon(Icons.edit_location_outlined)))
                          ],
                        )
                      ],
                    ),
                  ),
                  Divider(
                    color: Colors.white,
                  ),
                  mediaView(height(context), width(context), images),
                  Divider(
                    color: Colors.white,
                  ),
                  d['orderState'] > 8
                      ? warrentyCard(height(context), width(context))
                      : Container(),
                  Divider(
                    color: Colors.white,
                  ),
                  (d['orderState'] > 6)
                      ? Container(
                          // height: height(context) * 0.3,
                          color: Colors.white,
                          child: Column(
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(
                                    top: 15, left: 15, right: 15),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextWidget(
                                      text: 'Technician Details :',
                                      size: width(context) * 0.055,
                                      weight: FontWeight.w600,
                                    ),
                                  ],
                                ),
                              ),
                              d['pDetails'] != null
                                  ? partnerDetails(
                                      height(context),
                                      width(context),
                                      context,
                                      _postOverViewController,
                                      d,
                                      chatWithPatner,
                                      up)
                                  : Container(
                                      height: 60,
                                      alignment: Alignment.center,
                                      child: TextWid(
                                          text:
                                              "Unable to get Technician details")),
                            ],
                          ))
                      : Container(),
                  Container(
                    height: 500,
                    padding: EdgeInsets.only(left: 30, bottom: 50, top: 30),
                    // width: width(context) * 0.7,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        showOrderStatusQuestion && d['orderState'] != 3
                            ? Column(
                                children: [
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: TextWid(
                                      text: 'Is this order completed ?',
                                      size: width(context) * 0.055,
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                                  Container(
                                    margin:
                                        EdgeInsets.only(top: 20, bottom: 40),
                                    height: height(context) * 0.06,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButtonWidget(
                                          height: height(context) * 0.05,
                                          minWidth: width(context) * 0.35,
                                          onClick: () {
                                            isThisOrderCompleted(false);
                                          },
                                          bgColor: Colors.white,
                                          borderSideColor: Colors.grey[200],
                                          borderRadius: 10.0,
                                          buttonName: 'Not yet',
                                          textSize: width(context) * 0.04,
                                          leadingIcon: Icon(
                                            Icons.cancel,
                                            color: Colors.grey[900],
                                            size: width(context) * 0.045,
                                          ),
                                        ),
                                        ElevatedButtonWidget(
                                          height: height(context) * 0.05,
                                          minWidth: width(context) * 0.45,
                                          bgColor: Colors.indigo[900],
                                          borderSideColor: Colors.grey[200],
                                          borderRadius: 10.0,
                                          buttonName: 'Completed',
                                          onClick: () {
                                            newQueryBS(context,
                                                type: "number",
                                                heading: "How much you paid",
                                                hint:
                                                    "Enter amount you paid to partner",
                                                label: "Enter Money",
                                                onSubmit: (String value) {
                                              // log(value);
                                              isThisOrderCompleted(true,
                                                  orderID:
                                                      d['ordId'].toString(),
                                                  money: value);
                                            });
                                          },
                                          textColor: Colors.white,
                                          textSize: width(context) * 0.04,
                                          leadingIcon: Icon(
                                            Icons.check_circle,
                                            color: Colors.white,
                                            size: width(context) * 0.045,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : Container(),
                        Visibility(
                          visible: d['orderState'] < 3,
                          child: Container(
                            padding: EdgeInsets.only(bottom: 10, right: 10),
                            child: ElevatedButtonWidget(
                              height: height(context) * 0.05,
                              minWidth: width(context) * 0.5,
                              onClick: () {
                                Map<String, dynamic> sendPayload = {
                                  "socketName": "broadCastOrder",
                                  "ordId": d['ordId']
                                };
                                chatProvider.setSendMessage(sendPayload);
                              },
                              bgColor: Colors.white,
                              borderSideColor: Colors.grey[200],
                              borderRadius: 10.0,
                              buttonName: 'Send order again',
                              textSize: width(context) * 0.04,
                              leadingIcon: Icon(
                                Icons.refresh_rounded,
                                color: Colors.grey[900],
                                size: width(context) * 0.045,
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: d['orderState'] == 9 && d['pId'] != null,
                          child: Container(
                            padding: EdgeInsets.only(bottom: 10, right: 10),
                            child: ElevatedButtonWidget(
                              height: height(context) * 0.05,
                              minWidth: width(context) * 0.5,
                              onClick: () {
                                reviewBS(context,
                                    _postOverViewController.submitReview);
                              },
                              bgColor: Colors.white,
                              borderSideColor: Colors.grey[200],
                              borderRadius: 10.0,
                              buttonName: 'Rate Service',
                              textSize: width(context) * 0.04,
                              leadingIcon: Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: width(context) * 0.045,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: TextWid(
                            text: 'Service Status :',
                            size: width(context) * 0.055,
                            weight: FontWeight.w600,
                          ),
                        ),
                        Container(child: _Timeline2(context, orderData: d)),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          ProgressWaiter(contextt: context, loaderState: data.orderViewLoader)
        ],
      );
    });
  }

  serviceDetailsListTile(
    width,
    hight,
    title,
    icon,
    subtitle,
  ) {
    return ListTile(
        tileColor: Colors.redAccent,
        leading: Icon(
          icon,
          size: width * 0.045,
        ),
        title: TextWidget(
          text: title,
          size: width * 0.045,
          weight: FontWeight.w600,
          color: Colors.grey[900],
          lSpace: 1.5,
        ),
        subtitle: TextWidget(
          text: subtitle,
          size: width * 0.04,
          flow: TextOverflow.visible,
          weight: FontWeight.w600,
          color: Colors.grey[600],
          lSpace: 1,
        ),
        trailing: Container(
          width: width * 0.07,
        ));
  }

  mediaView(hight, width, images) {
    return Container(
      //height: hight * 0.22,
      color: Colors.white,
      padding: EdgeInsets.only(bottom: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(top: 15, left: 15, right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget(
                  text: 'Media Files :',
                  size: width * 0.055,
                  weight: FontWeight.w600,
                ),
              ],
            ),
          ),
          images.length > 0
              ? Container(
                  height: hight * 0.14,
                  child: ListView.builder(
                      itemCount: images.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            SizedBox(
                              width: width * 0.05,
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => MediaPlayer(
                                          mediaList: [images[index]],
                                        )));
                              },
                              child: Container(
                                  height: width * 0.15,
                                  width: width * 0.15,
                                  child: mediaContent(images[index],
                                      isOnline: true)),
                            )
                            // Container(
                            //   child: images[index].contains('jpg')
                            //       ? InkWell(
                            //           onTap: () {
                            //             imageslider(images, hight, width);
                            //           },
                            //           child: Container(
                            //             width: width * 0.11,
                            //             decoration: BoxDecoration(
                            //                 borderRadius:
                            //                     BorderRadius.circular(10),
                            //                 image: DecorationImage(
                            //                     image: NetworkImage(
                            //                         images[index]))),
                            //           ),
                            //         )
                            //       : images[index].contains('mp4')
                            //           ? TextWidget(
                            //               text: 'Video',
                            //             )
                            //           : TextWidget(text: 'Audio'),
                            // ),
                          ],
                        );
                      }),
                )
              : Container(
                  padding: EdgeInsets.only(top: 10),
                  child: TextWid(
                    text: 'No media files found',
                    align: TextAlign.center,
                  ),
                ),
        ],
      ),
    );
  }

  warrentyCard(hight, width) {
    return Container(
      height: hight * 0.2,
      width: width,
      margin: EdgeInsets.only(left: 10, right: 10),
      decoration: BoxDecoration(
          color: Colors.indigo[900],
          border: Border.all(color: Colors.indigo[900]),
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Container(
            // alignment: Alignment.topLeft,
            padding: EdgeInsets.only(left: 20, right: 10),
            width: width * 0.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextWidget(
                  text: 'Warranty Card',
                  color: Colors.white,
                  size: width * 0.05,
                  weight: FontWeight.w600,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: 'VALID TILL',
                      color: Colors.indigo[200],
                      size: width * 0.035,
                      weight: FontWeight.w600,
                    ),
                    TextWidget(
                      text: '09 Oct,2021',
                      color: Colors.white,
                      size: width * 0.04,
                      weight: FontWeight.w600,
                    ),
                  ],
                ),
                TextWidget(
                  text: 'Claim Warranty >>',
                  color: Colors.white,
                  size: width * 0.045,
                  weight: FontWeight.w600,
                )
              ],
            ),
          ),
          Container(
            width: width * 0.3,
            child: SvgPicture.asset('assets/like.svg'),
          )
        ],
      ),
    );
  }

  rating() {
    showDialog(
        context: context,
        barrierDismissible: true, // set to false if you want to force a rating
        builder: (context) {
          return RatingDialog(
            icon: Icon(
              Icons.rate_review,
              size: 100,
              color: Colors.blue[800],
            ),
            // const FlutterLogo(
            //   size: 100,
            // ), // set your own image/icon widget
            title: "Rate Your Technician!",
            description: "Express Your Experience By Tapping \nOn Stars",
            submitButton: "SUBMIT",
            alternativeButton: "Contact us instead?", // optional
            positiveComment: "We are so happy to hear :)", // optional
            negativeComment: "We're sad to hear :(", // optional
            accentColor: Colors.blue[800], // optional
            onSubmitPressed: (int rating) {
              print("onSubmitPressed: rating = $rating");
            },
            onAlternativePressed: () {
              print("onAlternativePressed: do something");
            },
          );
        });
  }

  imageslider(List<String> images, double hight, double width) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.zero,
            contentPadding: EdgeInsets.zero,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            actions: [
              Container(
                  height: hight * 0.35,
                  width: width * 1,
                  child: CarouselSlider.builder(
                    itemCount: images.length,
                    itemBuilder: (ctx, index, realIdx) {
                      return Container(
                          child: Image.network(images[index]
                              .substring(0, images[index].length - 1)));
                    },
                    options: CarouselOptions(
                      autoPlayInterval: Duration(seconds: 3),
                      autoPlayAnimationDuration: Duration(milliseconds: 800),
                      autoPlay: false,
                      aspectRatio: 2.0,
                      enlargeCenterPage: true,
                    ),
                  ))
            ],
          );
        });
  }
}

partnerDetails(hight, width, BuildContext context, controller, orderDetails,
    chatWithPatner, UniversalProvider up) {
  dynamic pDetails = orderDetails['pDetails'];
  log(pDetails['lang'].toString());
  List languages = pDetails['lang'];
  return Container(
    // height: hight * 0.24,
    child: Column(
      children: [
        Container(
            padding: EdgeInsets.only(left: 30, right: 30, top: 30),
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ProfilePic(
                  profile: pDetails['partnerPic'],
                  name: pDetails['name'],
                  size: hight * 0.05,
                ),
                SizedBox(
                  width: width * 0.07,
                ),
                Container(
                  height: hight * 0.11,
                  width: width * 0.5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Row(
                            children: [
                              TextWidget(
                                text: toBeginningOfSentenceCase(
                                  pDetails['name'],
                                ),
                                size: width * 0.04,
                                weight: FontWeight.w600,
                                color: Colors.grey[900],
                              )
                            ],
                          ),
                          Container(
                            child: Row(
                              // mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                TextWidget(
                                  text: up.getServiceNameById(pDetails['job']) +
                                      ' | ',
                                  size: width * 0.025,
                                  weight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                                TextWidget(
                                  // text: pDetails['rate'][0].toString(),
                                  text: '4.5',
                                  size: width * 0.025,
                                  weight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                                Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: width * 0.025,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        child: Row(
                            children: languages
                                .map((lang) => Container(
                                      child: TextWid(
                                        text: lang + "  ",
                                        size: width * 0.026,
                                        weight: FontWeight.w600,
                                        color: Colors.grey[900],
                                      ),
                                    ))
                                .toList()),
                      ),
                      Container(
                        width: width * 0.45,
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_pin,
                              size: width * 0.03,
                            ),
                            TextWid(
                              text: 'vizag',
                              size: width * 0.03,
                              weight: FontWeight.w600,
                              color: Colors.grey[900],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )),
        SizedBox(
          height: hight * 0.01,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              onTap: () {
                bottomOptionsMenu(context,
                    options: Constants.bottomSheetOptionsForCalling,
                    option1Click: () {
                  launch("tel://${orderDetails['pDetails']['phNum']}");
                }, option2Click: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => MyCalling(
                            ordId: orderDetails['ordId'].toString(),
                            uId: orderDetails['uDetails']['uId'],
                            pId: orderDetails['pDetails']['pId'],
                            isIncoming: false,
                            name: orderDetails['pDetails']['name'].toString(),
                            profile: orderDetails['pDetails']['partnerPic']
                                .toString(),
                            partnerDeviceToken: orderDetails['pDetails']
                                    ['partnerDeviceToken']
                                .toString(),
                          )));
                });
              },
              child: Row(
                children: [
                  CircleAvatar(
                    radius: width * 0.06,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.call,
                      color: Colors.grey[900],
                      size: width * 0.05,
                    ),
                  ),
                  SizedBox(
                    height: hight * 0.01,
                  ),
                  TextWidget(
                    text: 'Call',
                    size: width * 0.04,
                    weight: FontWeight.w600,
                    color: Colors.grey[900],
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                chatWithPatner(orderDetails);
              },
              child: Row(
                children: [
                  CircleAvatar(
                    radius: width * 0.06,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.chat_bubble,
                      color: Colors.grey[900],
                      size: width * 0.05,
                    ),
                  ),
                  SizedBox(
                    height: hight * 0.01,
                  ),
                  TextWidget(
                    text: 'Message',
                    size: width * 0.04,
                    weight: FontWeight.w600,
                    color: Colors.grey[900],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

enum _TimelineStatus { request, accept, started, completed, feedback }

const kTileHeight = 90.0;

class _Timeline2 extends StatelessWidget {
  final BuildContext contextt;
  final dynamic orderData;
  _Timeline2(this.contextt, {@required this.orderData});
  isServiceStarted() {
    int schedule = orderData['schedule'].runtimeType == String
        ? int.parse(orderData['schedule'])
        : orderData['schedule'];
    int presentTimestamp = DateTime.now().millisecondsSinceEpoch;
    // if (orderData['orderState'] < 8) return false;
    if (schedule < presentTimestamp) {
      if (orderData['orderState'] > 6) {
        return true;
      }
      return false;
    }
    if (orderData['orderState'] > 6) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final data = _TimelineStatus.values;
    return Flexible(
      child: Timeline.tileBuilder(
        theme: TimelineThemeData(
          nodePosition: 0,
          connectorTheme: ConnectorThemeData(
            thickness: 3.0,
            space: 20,
            color: Color(0xffd3d3d3),
          ),
          indicatorTheme: IndicatorThemeData(
            size: width(context) * 0.06,
          ),
        ),
        //padding: EdgeInsets.symmetric(vertical: 5.0),
        builder: TimelineTileBuilder.connected(
          contentsBuilder: (_, index) {
            return TimeLineTitle(
                index, contextt, orderData['orderState'], isServiceStarted());
          },
          connectorBuilder: (_, index, connectorType) {
            var solidLineConnector = SolidLineConnector(
              color: Colors.indigo[700],
              indent: connectorType == ConnectorType.start ? 0 : 2.0,
              endIndent: connectorType == ConnectorType.end ? 0 : 2.0,
            );
            var solidLineConnectorEmpty = SolidLineConnector(
              indent: connectorType == ConnectorType.start ? 0 : 2.0,
              endIndent: connectorType == ConnectorType.end ? 0 : 2.0,
            );
            switch (index) {
              case 0:
                return solidLineConnector;
                break;
              case 1:
                if (orderData['orderState'] > 6) return solidLineConnector;
                return solidLineConnectorEmpty;
              case 2:
                if (orderData['orderState'] > 8) return solidLineConnector;
                return solidLineConnectorEmpty;
              case 3:
                if (orderData['orderState'] > 9) return solidLineConnector;
                return solidLineConnectorEmpty;
              default:
                return solidLineConnectorEmpty;
            }
          },
          indicatorBuilder: (_, index) {
            switch (data[index]) {
              case _TimelineStatus.request:
                return DotIndicator(
                  color: Colors.indigo[900],
                  child: Icon(
                    Icons.work_rounded,
                    color: Colors.grey[300],
                    size: width(context) * 0.035,
                  ),
                );
              case _TimelineStatus.accept:
                return DotIndicator(
                  color: orderData['orderState'] > 6
                      ? Colors.indigo[900]
                      : Colors.grey,
                  child: Icon(
                    Icons.how_to_reg_rounded,
                    size: width(context) * 0.035,
                    color: Colors.grey[300],
                  ),
                );
              case _TimelineStatus.started:
                return DotIndicator(
                  color: isServiceStarted() ? Colors.indigo[900] : Colors.grey,
                  child: Icon(
                    Icons.build,
                    size: width(context) * 0.035,
                    color: Colors.grey[300],
                  ),
                );
              case _TimelineStatus.completed:
                return DotIndicator(
                  color: orderData['orderState'] > 8
                      ? Colors.indigo[900]
                      : Colors.grey,
                  child: Icon(
                    Icons.verified_rounded,
                    size: width(context) * 0.035,
                    color: Colors.grey[300],
                  ),
                );
              case _TimelineStatus.feedback:
                return DotIndicator(
                  color: orderData['orderState'] > 9
                      ? Colors.indigo[900]
                      : Colors.grey,
                  child: Icon(
                    Icons.reviews,
                    size: width(context) * 0.035,
                    color: Colors.grey[300],
                  ),
                );
              default:
                return DotIndicator(
                  color: Colors.indigo[900],
                  child: Icon(
                    Icons.verified_rounded,
                    size: width(context) * 0.035,
                    color: Colors.white,
                  ),
                );
            }
          },
          itemExtentBuilder: (_, __) => kTileHeight,
          itemCount: data.length,
        ),
      ),
    );
  }
}

class TimeLineTitle extends StatelessWidget {
  final int index;
  final BuildContext contextt;
  final int orderState;
  final bool orderStarted;
  TimeLineTitle(this.index, this.contextt, this.orderState, this.orderStarted);
  getStatus() {
    switch (index) {
      case 0:
        return "Service Requested";
      case 1:
        return "Order Accepted";
      case 2:
        return "Service Started";
      case 3:
        return "Service Completed";
      case 4:
        return "Feedback";
      default:
        return "Something Went wrong";
        break;
    }
  }

  isCompleted() {
    if (index < 2) return true;
    switch (index) {
      case 2:
        if (orderStarted) return true;
        return false;
      case 3:
        if (orderState > 8) return true;
        return false;
      case 4:
        if (orderState > 9) return true;
        return false;
        break;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(left: width(context) * 0.03),
        child: TextWid(
          text: getStatus(),
          size: width(context) * 0.04,
          weight: FontWeight.w600,
          color: isCompleted() ? Colors.grey[850] : Colors.grey[600],
        ));
  }
}





// CustomScrollView(
        //   physics: const BouncingScrollPhysics(
        //       parent: AlwaysScrollableScrollPhysics()),
        //   slivers: [
        //     SliverAppBar(
        //         backgroundColor: Colors.blue[900],
        //         stretch: true,
        //         pinned: true,
        //         snap: false,
        //         floating: true,
        //         expandedHeight: height(context) * 0.5,
        //         flexibleSpace: FlexibleSpaceBar(
        //             stretchModes: <StretchMode>[
        //               StretchMode.zoomBackground,
        //               StretchMode.fadeTitle,
        //             ],
        //             title: Text(
        //               _postOverViewController.jobs.elementAt(d['job']),
        //             ),
        //             background: Container(
        //               width: width(context) * 1,
        //               color: Colors.black,
        //               child: GestureDetector(
        //                   onTap: () {
        //                     imageslider(images, height(context), width(context));
        //                   },
        //                   child: (images.isEmpty)
        //                       ? Icon(
        //                           Icons.tungsten_rounded,
        //                           color: Colors.amber,
        //                           size: width(context) * 0.5,
        //                         )
        //                       : Image.network(
        //                           images.first,
        //                           fit: BoxFit.cover,
        //                         )),
        //             ))),
        //     SliverList(
        //         delegate: SliverChildListDelegate([
        //       Container(
        //         padding:
        //             EdgeInsets.only(left: width(context) * 0.08, top: width(context) * 0.03),
        //         height: height(context) * 0.07,
        //         child: Column(
        //           mainAxisAlignment: MainAxisAlignment.center,
        //           crossAxisAlignment: CrossAxisAlignment.start,
        //           children: [
        //             Text('Orderid:',
        //                 style: TextStyle(
        //                     color: Colors.grey[700],
        //                     fontWeight: FontWeight.bold)),
        //             Text(d['ordId'].toString()),
        //           ],
        //         ),
        //       ),
        //       Divider(
        //         thickness: 4,
        //         color: Colors.grey[200],
        //       ),
        //       Container(
        //         padding: EdgeInsets.only(right: 5, left: 5),
        //         height: height(context) * 0.032,
        //         decoration: BoxDecoration(
        //             color: Colors.white,
        //             borderRadius: BorderRadius.circular(5)),
        //         child: Row(
        //           mainAxisAlignment: MainAxisAlignment.center,
        //           children: [
        //             Icon(
        //               _postOverViewController.orderStateIcon(d['ordState']),
        //               color: Colors.indigo[900],
        //               size: width(context) * 0.04,
        //             ),
        //             SizedBox(
        //               width: width(context) * 0.01,
        //             ),
        //             TextWidget(
        //                 text: _postOverViewController
        //                     .orderStateText(d['ordState']),
        //                 color: Colors.indigo[900],
        //                 weight: FontWeight.w600,
        //                 size: width(context) * 0.03)
        //           ],
        //         ),
        //       ),
        //       Container(
        //         padding:
        //             EdgeInsets.only(left: width(context) * 0.09, right: width(context) * 0.02),
        //         height: height(context) * 0.1,
        //         child: Row(
        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //           children: [
        //             Container(
        //               width: width(context) * 0.7,
        //               child: Column(
        //                 mainAxisAlignment: MainAxisAlignment.center,
        //                 crossAxisAlignment: CrossAxisAlignment.start,
        //                 children: [
        //                   Text('Problem:',
        //                       style: TextStyle(
        //                           color: Colors.grey[700],
        //                           fontWeight: FontWeight.bold)),
        //                   Flexible(
        //                     child: Text(
        //                       d['problem'],
        //                       overflow: TextOverflow.ellipsis,
        //                       style: TextStyle(color: Colors.grey[800]),
        //                     ),
        //                   ),
        //                 ],
        //               ),
        //             ),
        //             _postOverViewController.editAttributes(
        //                 'problem',
        //                 ordId.toString(),
        //                 d['job'],
        //                 d['money'],
        //                 d['schedule'],
        //                 coordinates),
        //           ],
        //         ),
        //       ),
        //       Divider(
        //         thickness: 4,
        //         color: Colors.grey[200],
        //       ),
        //       Container(
        //         padding:
        //             EdgeInsets.only(left: width(context) * 0.09, right: width(context) * 0.02),
        //         height: height(context) * 0.1,
        //         child: Row(
        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //           children: [
        //             Column(
        //               mainAxisAlignment: MainAxisAlignment.center,
        //               crossAxisAlignment: CrossAxisAlignment.start,
        //               children: [
        //                 Text('Amount quoted:',
        //                     style: TextStyle(
        //                         color: Colors.grey[700],
        //                         fontWeight: FontWeight.bold)),
        //                 Text('₹' + d['money'].toString(),
        //                     style: TextStyle(
        //                       color: Colors.grey[700],
        //                     )),
        //                 // Text(d['ordId']),
        //               ],
        //             ),
        //             _postOverViewController.editAttributes(
        //                 'amount',
        //                 ordId.toString(),
        //                 d['job'],
        //                 d['money'],
        //                 d['schedule'],
        //                 coordinates),
        //           ],
        //         ),
        //       ),
        //       Divider(
        //         thickness: 4,
        //         color: Colors.grey[200],
        //       ),
        //       Container(
        //         padding:
        //             EdgeInsets.only(left: width(context) * 0.09, right: width(context) * 0.02),
        //         height: height(context) * 0.1,
        //         child: Row(
        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //           children: [
        //             Column(
        //               mainAxisAlignment: MainAxisAlignment.center,
        //               crossAxisAlignment: CrossAxisAlignment.start,
        //               children: [
        //                 Text('Schedule:',
        //                     style: TextStyle(
        //                         color: Colors.grey[700],
        //                         fontWeight: FontWeight.bold)),
        //                 Text(
        //                     DateFormat('dd/MM/yyyy').format(
        //                         DateTime.fromMillisecondsSinceEpoch(
        //                             d['schedule'])),
        //                     style: TextStyle(
        //                       color: Colors.grey[700],
        //                     ))
        //               ],
        //             ),
        //             _postOverViewController.editAttributes(
        //                 'Schedule',
        //                 ordId.toString(),
        //                 d['job'],
        //                 d['money'],
        //                 d['schedule'],
        //                 coordinates),
        //           ],
        //         ),
        //       ),
        //       Divider(
        //         thickness: 4,
        //         color: Colors.grey[200],
        //       ),
        //       Container(
        //         padding:
        //             EdgeInsets.only(left: width(context) * 0.09, right: width(context) * 0.02),
        //         height: height(context) * 0.1,
        //         child: Row(
        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //           children: [
        //             Column(
        //               mainAxisAlignment: MainAxisAlignment.center,
        //               crossAxisAlignment: CrossAxisAlignment.start,
        //               children: [
        //                 Text('Service location:',
        //                     style: TextStyle(
        //                         color: Colors.grey[700],
        //                         fontWeight: FontWeight.bold)),
        //                 Text(
        //                     d['loc'][0].toString() +
        //                         ',' +
        //                         d['loc'][1].toString(),
        //                     style: TextStyle(
        //                       color: Colors.grey[700],
        //                     ))
        //               ],
        //             ),
        //             _postOverViewController.editAttributes(
        //                 'location',
        //                 ordId.toString(),
        //                 d['job'],
        //                 d['money'],
        //                 d['schedule'],
        //                 coordinates),
        //           ],
        //         ),
        //       ),
        //       d['ordstate'] == 'req'
        //           ? Container(
        //               color: Colors.blue[900],
        //               child: IconButton(
        //                   onPressed: () {
        //                     rating();
        //                   },
        //                   icon: Row(
        //                     mainAxisAlignment: MainAxisAlignment.center,
        //                     children: [
        //                       Text(
        //                         'Rate',
        //                         style: TextStyle(
        //                             color: Colors.white,
        //                             fontSize: width(context) * 0.05),
        //                       ),
        //                       Icon(
        //                         Icons.star,
        //                         color: Colors.white,
        //                       ),
        //                     ],
        //                   )),
        //             )
        //           : Container(
        //               color: Colors.blue[900],
        //               child: IconButton(
        //                   icon: Row(
        //                     mainAxisAlignment: MainAxisAlignment.center,
        //                     children: [
        //                       Text(
        //                         'Complete',
        //                         style: TextStyle(color: Colors.white),
        //                       ),
        //                       Icon(
        //                         Icons.done,
        //                         color: Colors.white,
        //                       ),
        //                     ],
        //                   ),
        //                   onPressed: () {}),
        //             ),
        //     ])),
        //   ],
        // );
