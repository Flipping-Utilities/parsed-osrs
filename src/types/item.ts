export interface Item {
  // The item id
  id: number;
  // Item name
  name: string;
  // Image url
  image?: string | string[];
  // Examine text
  examine: string;
  // Can this item be traded between players
  isTradeable: boolean;
  // Is this item listed on the GE
  isOnGrandExchange: boolean;
  // Is this item members, f2p or unknown
  isMembers: boolean | null;
  // Items directly related to this item: Charged variants, potion doses
  relatedItems: number[];
  // Can this item stacked
  isStackable: boolean;
  // Can this item be equiped
  isEquipable: boolean;
  // OSRS Cost: used to compute the other values such as alch
  value: number;
  // Can this item be high alched
  isAlchable: boolean;
  // // Low alch value
  // lowalch: number;
  // // High alch value
  // highalch: number;
  // Available left click options
  options: string[];
  // Can this item be dropped, or does it have a special action like "Destroy"
  drop: string;
  // Weight when carried
  weight: number | null;
  // GE Buy limit
  limit: number;

  // Not a removed or seasonal item
  isInMainGame: boolean | null;
}
