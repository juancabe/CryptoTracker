//
//  CryptocurrencyData.swift
//  CryptoTracker
//
//  Created by Juan Calzada Bernal on 23/12/24.
//


import Foundation

import Foundation

struct CryptocurrencyData: Codable {
    let id: String
    let symbol: String
    let name: String
    let web_slug: String?
    let asset_platform_id: String?
    let platforms: [String: String]
    let detail_platforms: [String: DetailPlatform]
    let block_time_in_minutes: Int?
    let hashing_algorithm: String?
    let categories: [String]
    let preview_listing: Bool
    let public_notice: String?
    let additional_notices: [String]
    let localization: [String: String]
    let description: [String: String]
    let links: Links
    let image: Image
    let country_origin: String?
    let genesis_date: String?
    let sentiment_votes_up_percentage: Double?
    let sentiment_votes_down_percentage: Double?
    let watchlist_portfolio_users: Int?
    let market_cap_rank: Int?
    let market_data: MarketData
    let community_data: CommunityData
    let developer_data: DeveloperData
    let status_updates: [String]
    let last_updated: String?
    
    struct DetailPlatform: Codable {
        let decimal_place: Int?
        let contract_address: String
    }
    
    struct Links: Codable {
        let homepage: [String]?
        let whitepaper: String?
        let blockchain_site: [String]?
        let official_forum_url: [String]?
        let chat_url: [String]?
        let announcement_url: [String]?
        let snapshot_url: String?
        let twitter_screen_name: String?
        let facebook_username: String?
        let bitcointalk_thread_identifier: Int?
        let telegram_channel_identifier: String?
        let subreddit_url: String?
        let repos_url: ReposURL?
        
        struct ReposURL: Codable {
            let github: [String]?
            let bitbucket: [String]?
        }
    }
    
    struct Image: Codable {
        let thumb: String
        let small: String
        let large: String
    }
    
    struct MarketData: Codable {
        let current_price: [String: Double]
        let total_value_locked: Double?
        let mcap_to_tvl_ratio: Double?
        let fdv_to_tvl_ratio: Double?
        let ath: [String: Double]
        let ath_change_percentage: [String: Double]
        let ath_date: [String: String]
        let atl: [String: Double]
        let atl_change_percentage: [String: Double]
        let atl_date: [String: String]
        let market_cap: [String: Double]
        let fully_diluted_valuation: [String: Double]
        let market_cap_fdv_ratio: Double?
        let total_volume: [String: Double]
        let high_24h: [String: Double]
        let low_24h: [String: Double]
        let price_change_24h: Double
        let price_change_percentage_24h: Double
        let price_change_percentage_7d: Double
        let price_change_percentage_14d: Double
        let price_change_percentage_30d: Double
        let price_change_percentage_60d: Double
        let price_change_percentage_200d: Double
        let price_change_percentage_1y: Double
        let market_cap_change_24h: Double
        let market_cap_change_percentage_24h: Double
        let price_change_24h_in_currency: [String: Double]
        let price_change_percentage_1h_in_currency: [String: Double]
        let price_change_percentage_24h_in_currency: [String: Double]
        let price_change_percentage_7d_in_currency: [String: Double]
        let price_change_percentage_14d_in_currency: [String: Double]
        let price_change_percentage_30d_in_currency: [String: Double]
        let price_change_percentage_60d_in_currency: [String: Double]
        let price_change_percentage_200d_in_currency: [String: Double]
        let price_change_percentage_1y_in_currency: [String: Double]
        let market_cap_change_24h_in_currency: [String: Double]
        let market_cap_change_percentage_24h_in_currency: [String: Double]
        let total_supply: Decimal?
        let max_supply: Decimal?
        let circulating_supply: Decimal?
        let last_updated: String
    }
    
    struct CommunityData: Codable {
        let facebook_likes: Int?
        let twitter_followers: Int
        let reddit_average_posts_48h: Int
        let reddit_average_comments_48h: Int
        let reddit_subscribers: Int
        let reddit_accounts_active_48h: Int
        let telegram_channel_user_count: Int?
    }
    
    struct DeveloperData: Codable {
        let forks: Int?
        let stars: Int?
        let subscribers: Int?
        let total_issues: Int?
        let closed_issues: Int?
        let pull_requests_merged: Int?
        let pull_request_contributors: Int?
        let code_additions_deletions_4_weeks: CodeAdditionsDeletions?
        let commit_count_4_weeks: Int?
        let last_4_weeks_commit_activity_series: [String]?
        
        struct CodeAdditionsDeletions: Codable {
            let additions: Int?
            let deletions: Int?
        }
    }
}
