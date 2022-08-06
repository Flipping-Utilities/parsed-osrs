export interface ShopItem {
    itemId: number;
    baseQuantity: number;
    // Number of ticks between each stock, or 0.6s * this number
    restockTime: number;
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
  inventory: ShopItem[];
}