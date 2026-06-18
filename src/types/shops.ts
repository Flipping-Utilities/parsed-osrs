export interface ShopItem {
  itemId: number;
  baseQuantity: number;
  // Number of ticks between each stock, or 0.6s * this number
  restockTime: number;
  // Per-item buy price when explicitly specified
  buyPrice?: number;
  // Per-item cost when explicitly specified
  cost?: number;
  // Whether the item is traded on the Grand Exchange (when specified)
  isOnGrandExchange?: boolean;
}

export interface Shop {
  name: string;
  pageId: number;
  // % value of the item of which the shops sells the items
  sellPercent: number;
  // % value of the item of which the shops buys the items
  buyPercent: number;
  // When selling multiple item, each item will decrease the buy percent by this much
  buyChangePercent: number;
  // Where the shop is located
  location: string;
  // NPC(s) that own the shop
  owner: string;
  // Members-only access (null when unspecified)
  isMembers: boolean | null;
  // Currency used by the shop (e.g. "Coins", "Tokkul"); empty when default
  currency: string;
  // Shop type categorization (e.g. "General store", "Specialty")
  specialty: string;
  inventory: ShopItem[];
}
