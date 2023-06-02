class ConCi {
  String? tlId;
  String? uuid;
  String? userState;
  int? wTime;
  String? wKind;
  String? ais;
  String? timestamp;

  ConCi(
      {this.tlId,
      this.uuid,
      this.userState,
      this.wTime,
      this.wKind,
      this.ais,
      this.timestamp});

  ConCi.fromJson(Map<String, dynamic> json) {
    tlId = json['tl_id'];
    uuid = json['uuid'];
    userState = json['user_state'];
    wTime = json['w_time'];
    wKind = json['w_kind'];
    ais = json['ais'];
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['tl_id'] = tlId;
    data['uuid'] = uuid;
    data['user_state'] = userState;
    data['w_time'] = wTime;
    data['w_kind'] = wKind;
    data['ais'] = ais;
    data['timestamp'] = timestamp;
    return data;
  }
}
