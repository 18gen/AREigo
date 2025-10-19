//
//  LabelTranslator.swift
//  AREigo
//
//  Created by Gen Ichihashi on 2025-10-19.
//

import Foundation
import CoreFoundation

struct LabelTranslator {
    /// Normalize Vision/CoreML labels to improve dictionary hits.
    private func normalize(_ s: String) -> String {
        s.lowercased()
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Common synonyms → canonical keys
    private static let synonyms: [String: String] = [
        "tv": "television", "tv monitor": "television",
        "mobile phone": "cell phone", "smartphone": "cell phone",
        "laptop": "laptop computer", "notebook": "laptop computer",
        "hand bag": "handbag", "dining table": "table", "couch": "sofa",
        "tennis racquet": "tennis racket", "hair dryer": "hair drier",
        "traffic signal": "traffic light", "aeroplane": "airplane"
    ]

    /// EN→JA dictionary (lowercased keys). Extend as you meet new labels.
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
        "donut":"ドーナツ", "cake":"ケーキ", "chair":"椅子", "sofa":"ソファ", "potted plant":"観葉植物",
        "bed":"ベッド", "table":"テーブル", "toilet":"トイレ", "television":"テレビ",
        "laptop computer":"ノートPC", "mouse":"マウス", "remote":"リモコン", "keyboard":"キーボード",
        "cell phone":"スマホ", "microwave":"電子レンジ", "oven":"オーブン", "toaster":"トースター", "sink":"流し台",
        "refrigerator":"冷蔵庫", "book":"本", "clock":"時計", "vase":"花瓶", "scissors":"はさみ",
        "teddy bear":"テディベア", "hair drier":"ドライヤー", "toothbrush":"歯ブラシ",

        // Extra common Vision taxonomy terms
        "computer keyboard":"キーボード", "computer mouse":"マウス",
        "laptop":"ノートPC", "desktop computer":"デスクトップPC",
        "television set":"テレビ", "monitor":"モニター",
        "bottlecap":"ボトルキャップ", "coffee cup":"コーヒーカップ",
        "water bottle":"水筒", "wine bottle":"ワインボトル",
        "bookcase":"本棚", "sunglasses":"サングラス",
        "shoes":"靴", "shoe":"靴", "boot":"ブーツ", "sneaker":"スニーカー"
    ]

    /// Very lightweight fallback: try Katakana transliteration (no network).
    private func katakanaFallback(_ english: String) -> String? {
        let cleaned = english
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
        let ms = NSMutableString(string: cleaned) as CFMutableString
        // Normalize to Latin ASCII then to Katakana (ICU transliteration)
        let ok1 = CFStringTransform(ms, nil, "Any-Latin; Latin-ASCII" as CFString, false)
        let ok2 = CFStringTransform(ms, nil, "Latin-Katakana" as CFString, false)
        return (ok1 && ok2) ? (ms as String) : nil
    }

    func japanese(for rawEnglish: String) -> String {
        let key0 = normalize(rawEnglish)
        let key = Self.synonyms[key0] ?? key0
        if let hit = Self.dict[key] { return hit }
        if let kana = katakanaFallback(rawEnglish) { return kana }
        // Last resort: show something different from English to avoid EN/EN duplicate
        return "（\(rawEnglish)）"
    }
}
