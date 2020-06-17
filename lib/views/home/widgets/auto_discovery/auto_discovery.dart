import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

import '../../../../models/connection.dart';
import '../../../../shared/animator/fader.dart';
import '../../../../shared/basic/question_mark_tooltip.dart';
import '../../../../stores/views/home.dart';
import '../../../../utils/validation_helper.dart';
import 'session_tile.dart';

class AutoDiscovery extends StatefulWidget {
  @override
  _AutoDiscoveryState createState() => _AutoDiscoveryState();
}

class _AutoDiscoveryState extends State<AutoDiscovery> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    HomeStore landingStore = Provider.of<HomeStore>(context);

    return Column(
      // mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 24.0, right: 24.0, left: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flexible(
                child: Text('Port for autodiscovery: '),
              ),
              Container(width: 10.0),
              QuestionMarkTooltip(
                  message:
                      'Usually 4444. Can be seen and changed in the WebSocket Plugin settings in OBS (Tools -> WebSocket Plugin)'),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(bottom: 24.0),
          width: 65.0,
          child: Form(
            key: _formKey,
            child: TextFormField(
              textAlign: TextAlign.center,
              controller:
                  TextEditingController(text: landingStore.autodiscoverPort),
              onChanged: (text) {
                landingStore.setAutodiscoverPort(text);
                _formKey.currentState.validate();
              },
              validator: (text) => ValidationHelper.portValidation(text),
            ),
          ),
        ),
        Divider(
          height: 0.0,
        ),
        Observer(
          builder: (context) => FutureBuilder<List<Connection>>(
            future: landingStore.autodiscoverConnections,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  if (snapshot.data.length > 0) {
                    return Fader(
                      child: Column(
                        children: snapshot.data
                            .map(
                              (availableObsConnection) => SessionTile(
                                connection: availableObsConnection,
                              ),
                            )
                            .toList(),
                      ),
                    );
                  }
                  return Container(
                    padding: EdgeInsets.only(left: 24.0, right: 24.0),
                    alignment: Alignment.center,
                    height: 150.0,
                    child: Fader(
                      child: Text(
                        'Could not find an open OBS session via autodiscovery! Make sure you have an open OBS session in your local network with the OBS WebSocket plugin installed!\n\nPull down to try again!',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Container(
                    padding: EdgeInsets.only(left: 24.0, right: 24.0),
                    alignment: Alignment.center,
                    height: 150.0,
                    child: Fader(
                      child: Text(
                        'Network error occured! Make sure you are connected to your local network!\n\nPull down to try again!',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
              }
              return Align(
                child: Container(
                  height: 150.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(
                        strokeWidth: 2.0,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 12.0),
                        child: Text('Searching...'),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}