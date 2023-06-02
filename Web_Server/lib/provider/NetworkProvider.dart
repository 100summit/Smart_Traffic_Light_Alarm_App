import 'dart:convert';

import 'package:flutter_mobius/model/con.dart';
import 'package:flutter_mobius/model/con2.dart';
import 'package:flutter_mobius/model/reqTlInfo.dart';
import 'package:flutter_mobius/model/respGroupCi.dart';
import 'package:flutter_mobius/model/respGroupInfo.dart';
import 'package:flutter_mobius/model/reqTlState.dart';
import 'package:flutter_mobius/model/respGroupState.dart';
import 'package:flutter_mobius/model/respTlInfo.dart';
import 'package:flutter_mobius/model/respTlState.dart';
import 'package:http/http.dart' as http;

class NetworkProvider {
  Future<respTlState?> requestTlState(String tl, Con2 state) async {
    Uri uri = Uri.parse('http://127.0.0.1:7579/Mobius/$tl/state');

    final response = await http.post(uri,
        headers: {
          "accept": "application/json",
          "X-M2M-RI": "12345",
          "X-M2M-Origin": "Summit",
          "Content-Type": "application/json;ty=4"
        },
        body: jsonEncode(reqTlState(m2mCin: M2mCin2(con: state))));

    if (response.statusCode == 201) {
      return respTlState.fromJson(jsonDecode(response.body));
    } else {
      print(response.body);
    }
    return null;
  }

  Future<respTlInfo?> requestTlInfo(String tl, Con state) async {
    Uri uri = Uri.parse('http://127.0.0.1:7579/Mobius/$tl/info');

    final response = await http.post(uri,
        headers: {
          "accept": "application/json",
          "X-M2M-RI": "12345",
          "X-M2M-Origin": "Summit",
          "Content-Type": "application/json;ty=4"
        },
        body: jsonEncode(reqTlInfo(m2mCin: M2mCins(con: state))));

    if (response.statusCode == 201) {
      return respTlInfo.fromJson(jsonDecode(response.body));
    } else {
      print(response.body);
    }
    return null;
  }

  Future<respGroupInfo?> requestTlGroupInfo() async {
    Uri uri = Uri.parse('http://127.0.0.1:7579/Mobius/grp_tl_info/fopt');

    final response = await http.get(uri, headers: {
      "accept": "application/json",
      "X-M2M-RI": "12345",
      "X-M2M-Origin": "SummitG"
    });

    if (response.statusCode == 200) {
      return respGroupInfo.fromJson(jsonDecode(response.body));
    } else {
      print(response.body);
    }
    return null;
  }

  Future<respGroupState?> requestTlGroupState() async {
    Uri uri = Uri.parse('http://127.0.0.1:7579/Mobius/grp_tl_state/fopt');

    final response = await http.get(uri, headers: {
      "accept": "application/json",
      "X-M2M-RI": "12345",
      "X-M2M-Origin": "SummitG"
    });

    if (response.statusCode == 200) {
      return respGroupState.fromJson(jsonDecode(response.body));
    } else {
      print(response.body);
    }
    return null;
  }

  Future<respGroupCi?> requestGroupCi() async {
    Uri uri = Uri.parse('http://127.0.0.1:7579/Mobius/grp_tl_ci/fopt');

    final response = await http.get(uri, headers: {
      "accept": "application/json",
      "X-M2M-RI": "12345",
      "X-M2M-Origin": "SummitG"
    });

    if (response.statusCode == 200) {
      return respGroupCi.fromJson(jsonDecode(response.body));
    } else {
      print(response.body);
    }
    return null;
  }

  Future<respGroupCi?> requestGeoQuery() async {
    Uri uri = Uri.parse('http://127.0.0.1:7579/Mobius/grp_tl_ci/fopt');

    final response = await http.get(uri, headers: {
      "accept": "application/json",
      "X-M2M-RI": "12345",
      "X-M2M-Origin": "SummitG"
    });

    if (response.statusCode == 200) {
      return respGroupCi.fromJson(jsonDecode(response.body));
    } else {
      print(response.body);
    }
    return null;
  }
}
