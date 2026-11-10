/* Crafting Tree Common CSS */
.crafting-tree {
    line-height: 0;
    overflow-x: auto;
}

.tabbertab .crafting-tree ul {
    margin-left: 0;
    justify-content: center;
}

.crafting-tree ul {
    display: flex;
    padding: 0 0 0 0
}

.crafting-tree ul:not(:first-child) {
    margin: 34px 0px 0px 0px;
}

.crafting-tree li {
    display: flex;
    flex-direction: column;
    position: relative;
    align-items: center;
    font-weight: bold;
    font-family: system-ui;
    font-variant: small-caps;
}

/* Product/Ingredient/Input/etc. (the first span) */
.crafting-tree li > span:first-of-type {
    border: 1px solid var(--button-dark);
    outline: 1px solid var(--button-border);
    margin: 3px;

    /* Force a square area */
    width: 45px;
    height: 45px;
    box-sizing: border-box;

    /* Center whatever is inside */
    display: flex;
    align-items: center;
    justify-content: center;

    overflow: hidden;
}

/* Crafting facilities (everything but the first span) */
.crafting-tree span:not(:first-of-type) {
    position: relative;
    z-index: 0;
    border: none;
    top: 1px;
    height: 0; 
}

/* Connector: Elements with children - vertical line from bottom middle downwards */    
.crafting-tree li > ul::after {
    content: "";
    position: absolute;
    width: 2px;
    height: 26px;
    left: 50%;
    translate: 0px -38px;
    background-color: var(--button-border);
    z-index: -1;
    transform: translateX(-50%);
}
    
/* Connector: Elements with parent - vertical line from top middle upwards */    
.crafting-tree li > ul > li::before {
    content: "";
    position: absolute;
    top: -12px;
    left: 50%;
    width: 2px;
    height: 16px;
    background-color: var(--button-border);
    transform: translateX(-50%);
    z-index: -1;
}    
    
/* Connector: First child in a group - horizontal line from center to right (only if has siblings) */
.crafting-tree li > ul:has(> li + li) > li:first-child::after {
    content: "";
    position: absolute;
    top: -12px;
    left: 50%;
    width: 50%;
    height: 2px;
    background-color: var(--button-border);
    z-index: -1;
}

/* Connector: Last child in a group - horizontal line from left to center (only if has siblings) */
.crafting-tree li > ul:has(> li + li) > li:last-child::after {
    content: "";
    position: absolute;
    top: -12px;
    right: 50%;
    width: 50%;
    height: 2px;
    background-color: var(--button-border);
    z-index: -1;
}

/* Connector: Middle children - full horizontal line */
.crafting-tree li > ul > li:not(:first-child):not(:last-child)::after {
    content: "";
    position: absolute;
    top: -12px;
    width: 100%;
    height: 2px;
    background-color: var(--button-border);
    z-index: -1;
}

.crafting-tree ul:has(li:first-child:not(:last-child)) {
    margin-left: 6px;
    margin-right: 6px;
}

.crafting-tree a[href]:not(.mw-file-description):not(:has(img)) {
    line-height: 0.8;
    position: relative;
    /*top: -8px;*/
    align-content: center;
    text-align: center;
    text-decoration: none;
    height: 0px;
}

.tabbertab:has(.crafting-tree) {
	z-index: 1;
}

.crafting-tree  img {
    max-width: 45px !important;
    max-height: 45px !important;
    width: auto;
    height: auto;
    image-rendering: crisp-edges;
    
}

.crafting-tree span {
    background-color: var(--background-color-interactive--active);
}