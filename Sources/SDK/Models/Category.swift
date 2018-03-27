//
//  Category.swift
//  moltin
//
//  Created by Craig Tweedy on 22/02/2018.
//

import Foundation

/// Represents a `Category` in Moltin
public class Category: Codable, HasRelationship {
    /// The id of this category
    public let id: String
    /// The type of this object
    public let type: String
    /// The name of this category
    public let name: String
    /// The slug of this category
    public let slug: String
    /// The description of this category
    public let description: String
    /// live / draft
    public let status: String
    /// The relationships this category has
    public let relationships: Relationships?
    
    /// The categories associated with this category
    public var categories: [Category]?
    /// The products associated with this category
    public var products: [Product]?
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let includes: IncludesContainer = decoder.userInfo[.includes] as? IncludesContainer ?? [:]
        
        self.id = try container.decode(String.self, forKey: .id)
        self.type = try container.decode(String.self, forKey: .type)
        self.name = try container.decode(String.self, forKey: .name)
        self.slug = try container.decode(String.self, forKey: .slug)
        self.description = try container.decode(String.self, forKey: .description)
        self.status = try container.decode(String.self, forKey: .status)
        self.relationships = try container.decode(Relationships.self, forKey: .relationships)
        
        
        try self.decodeRelationships(fromRelationships: self.relationships, withIncludes: includes)
    }
}

extension Category {
    func decodeRelationships(
        fromRelationships relationships: Relationships?,
        withIncludes includes: IncludesContainer) throws {
        
        self.categories = try self.decodeMany(fromRelationships: self.relationships?[keyPath: \Relationships.categories],
                                          withIncludes: includes["categories"])
        
        self.products = try self.decodeMany(fromRelationships: self.relationships?[keyPath: \Relationships.products],
                                            withIncludes: includes["products"])
    }
}


