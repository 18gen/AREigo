//
//  LabelTranslator.swift
//  AREigo
//
//  Created by Gen Ichihashi on 2025-10-19.
//

import Foundation

struct LabelTranslator {
    // Basic EN -> JA mapping (common COCO-like classes; extend as needed)
    // If not found, we fall back to English.
    private static let dict: [String: String] = [
        "person":"人", "bicycle":"自転車", "car":"車", "motorcycle":"オートバイ", "airplane":"飛行機",
        "bus":"バス", "train":"電車", "truck":"トラック", "boat":"ボート", "traffic light":"信号",
        "fire hydrant":"消火栓", "stop sign":"一時停止標識", "parking meter":"パーキングメーター",
        "bench":"ベンチ", "bird":"鳥", "cat":"猫", "dog":"犬", "horse":"馬", "sheep":"羊", "cow":"牛",
        "elephant":"象", "bear":"熊", "zebra":"シマウマ", "giraffe":"キリン", "backpack":"リュック",
        "umbrella":"傘", "handbag":"ハンドバッグ", "tie":"ネクタイ", "suitcase":"スーツケース",
        "frisbee":"フリスビー", "skis":"スキー板", "snowboard":"スノーボード", "sports ball":"ボール",
        "kite":"凧", "baseball bat":"バット", "baseball glove":"グローブ", "skateboard":"スケートボード",
        "surfboard":"サーフボード", "tennis racket":"テニスラケット", "bottle":"ボトル", "wine glass":"ワイングラス",
        "cup":"コップ", "fork":"フォーク", "knife":"ナイフ", "spoon":"スプーン", "bowl":"ボウル",
        "banana":"バナナ", "apple":"りんご", "sandwich":"サンドイッチ", "orange":"オレンジ",
        "broccoli":"ブロッコリー", "carrot":"ニンジン", "hot dog":"ホットドッグ", "pizza":"ピザ",
        "donut":"ドーナツ", "cake":"ケーキ", "chair":"椅子", "couch":"ソファ", "potted plant":"観葉植物",
        "bed":"ベッド", "dining table":"ダイニングテーブル", "toilet":"トイレ", "tv":"テレビ", "laptop":"ノートPC",
        "mouse":"マウス", "remote":"リモコン", "keyboard":"キーボード", "cell phone":"スマホ",
        "microwave":"電子レンジ", "oven":"オーブン", "toaster":"トースター", "sink":"流し台",
        "refrigerator":"冷蔵庫", "book":"本", "clock":"時計", "vase":"花瓶", "scissors":"はさみ",
        "teddy bear":"テディベア", "hair drier":"ドライヤー", "toothbrush":"歯ブラシ"
    ]

    func japanese(for english: String) -> String {
        let key = english.lowercased()
        return Self.dict[key] ?? english
    }
}
