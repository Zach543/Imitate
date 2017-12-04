//
//  FirestoreModel.swift
//  Imitate
//
//  Created by Zach Kobes on 11/27/17.
//  Copyright © 2017 Zach Kobes. All rights reserved.
//

import FirebaseFirestore

private struct Property {
    let label: String
    let value: Any
}

struct FirestoreModelData {
    let snapshot: DocumentSnapshot
    
    var documentID: String {
        return snapshot.documentID
    }
    
    var data: [String : Any] {
        return snapshot.data()
    }
    
    func value<T>(forKey key: String) throws -> T {
        guard let value = data[key] as? T else { throw ModelDataError.typeCastFailed }
        return value
    }
    
    func value<T: RawRepresentable>(forKey key: String) throws -> T where T.RawValue == String {
        guard let value = data[key] as? String else { throw ModelDataError.typeCastFailed }
        return T(rawValue: value)!
    }
    
    func optionalValue<T>(forKey key: String) -> T? {
        return data[key] as? T
    }
    
    enum ModelDataError: Error {
        case typeCastFailed
    }
}

protocol StringRawRepresentable {
    var stringRawValue: String { get }
}

extension StringRawRepresentable where Self: RawRepresentable, Self.RawValue == String {
    var stringRawValue: String { return rawValue }
}

protocol FirestoreModel {
    init?(modelData: FirestoreModelData)
    
    var documentID: String! { get }
    var customID: String? { get }
    var serialized: [String : Any?] { get }
}

extension FirestoreModel {
    var serialized: [String : Any?] {
        var data = [String : Any?]()
        
        Mirror(reflecting: self).children.forEach { child in
            guard let property = child.label.flatMap({ Property(label: $0, value: child.value) }) else { return }
            
            switch property.value {
            case let rawRepresentable as StringRawRepresentable:
                data[property.label] = rawRepresentable.stringRawValue
            default:
                data[property.label] = property.value
            }
        }
        
        return data
    }
    
    var customID: String? { return nil }
}

extension DocumentReference {
    func setModel(_ model: FirestoreModel) {
        var documentData = [String : Any]()
        
        for (key, value) in model.serialized {
            if key == "documentID" || key == model.customID { continue }
            
            switch value {
            case let rawRepresentable as StringRawRepresentable:
                documentData[key] = rawRepresentable.stringRawValue
            default:
                documentData[key] = value
            }
        }
        
        setData(documentData)
    }
    
    func getModel<Model: FirestoreModel>(_: Model.Type, completion: @escaping (Model?, Error?) -> Void) {
        getDocument { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let snapshot = snapshot else {
                completion(nil, nil)
                return
            }
            
            completion(Model(modelData: FirestoreModelData(snapshot: snapshot)), nil)
        }
    }
}

extension CollectionReference {
    func addDoc(_ model: FirestoreModel, complete: @escaping (_ error: Error?) -> Void) {
        var documentData = [String : Any]()
        
        for (key, value) in model.serialized {
            if key == "documentID" || key == model.customID { continue }
            
            switch value {
            case let rawRepresentable as StringRawRepresentable:
                documentData[key] = rawRepresentable.stringRawValue
            default:
                documentData[key] = value
            }
        }
        
        addDocument(data: documentData) { (error) in
            complete(error)
        }
    }
}

extension Query {
    func getModels<Model: FirestoreModel>(_: Model.Type, completion: @escaping ([Model]?, Error?) -> Void) {
        getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let snapshot = snapshot else {
                completion(nil, nil)
                return
            }
            
            completion(snapshot.documents.flatMap { Model(modelData: FirestoreModelData(snapshot: $0)) }, nil)
        }
    }
    
    func addListener<Model: FirestoreModel>(_: Model.Type, completion: @escaping ([Model]?, Error?) -> Void) -> ListenerRegistration {
        return addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let querySnapshot = querySnapshot else {
                completion(nil, nil)
                return
            }
            
            completion(querySnapshot.documents.flatMap { Model(modelData: FirestoreModelData(snapshot: $0)) }, nil)
        }
    }

}

