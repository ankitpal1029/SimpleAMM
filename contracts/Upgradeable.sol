//SPDX-LIcense-Identifier: MIT
pragma solidity ^0.8.10;

contract Diamond {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.diamond.storage");

    struct FacetAddressAndSelectorPosition {
        address facetAddress;
        uint16 selectorPosition;
    }

    struct DiamondStorage {
        uint256 counter;
        mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
        bytes4[] selectors;
        address DiamondAdmin;
        address AdminA;
        address AdminB;
    }

    function diamondStorage()
        internal
        pure
        returns (DiamondStorage storage ds)
    {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    modifier diamondAdminOnly() {
        DiamondStorage storage ds = diamondStorage();
        require(ds.DiamondAdmin == msg.sender, "Not authorised to cut diamond");
        _;
    }

    function enforceHasContractCode(
        address _contract,
        string memory _errorMessage
    ) internal view {
        uint256 contractSize;
        assembly {
            contractSize := extcodesize(_contract)
        }
        require(contractSize > 0, _errorMessage);
    }

    constructor() {
        DiamondStorage storage ds = diamondStorage();
        ds.DiamondAdmin = msg.sender;
        ds.AdminB = msg.sender;
        ds.AdminA = msg.sender;
    }

    function addFunctions(
        address _facetAddress,
        bytes4[] memory _functionSelectors
    ) external diamondAdminOnly {
        require(_functionSelectors.length > 0, "No selectors in facet");
        DiamondStorage storage ds = diamondStorage();
        uint16 selectorCount = uint16(ds.selectors.length);
        require(_facetAddress != address(0), "Facet cannot have address(0)");
        enforceHasContractCode(_facetAddress, "Facet has no code");
        for (
            uint256 selectorIndex;
            selectorIndex < _functionSelectors.length;
            selectorIndex++
        ) {
            bytes4 selector = _functionSelectors[selectorIndex];
            address oldFacetAddress = ds
                .facetAddressAndSelectorPosition[selector]
                .facetAddress;
            require(
                oldFacetAddress == address(0),
                "Cannot add function that already exists"
            );
            ds.facetAddressAndSelectorPosition[
                    selector
                ] = FacetAddressAndSelectorPosition(
                _facetAddress,
                selectorCount
            );

            ds.selectors.push(selector);
            selectorCount++;
        }
    }

    function removeFunctions(
        bytes4[] memory _functionSelectors
    ) external diamondAdminOnly {
        require(_functionSelectors.length > 0, "No selectors");
        DiamondStorage storage ds = diamondStorage();
        uint256 selectorCount = ds.selectors.length;
        for (
            uint256 selectorIndex;
            selectorIndex < _functionSelectors.length;
            selectorIndex++
        ) {
            bytes4 selector = _functionSelectors[selectorIndex];
            FacetAddressAndSelectorPosition
                memory oldFacetAddressAndSelectorPosition = ds
                    .facetAddressAndSelectorPosition[selector];
            require(
                oldFacetAddressAndSelectorPosition.facetAddress != address(0),
                "Cannot remove function that doesn't exist"
            );
            // replace selector with last selector
            selectorCount--;
            if (
                oldFacetAddressAndSelectorPosition.selectorPosition !=
                selectorCount
            ) {
                bytes4 lastSelector = ds.selectors[selectorCount];
                ds.selectors[
                    oldFacetAddressAndSelectorPosition.selectorPosition
                ] = lastSelector;
                ds
                    .facetAddressAndSelectorPosition[lastSelector]
                    .selectorPosition = oldFacetAddressAndSelectorPosition
                    .selectorPosition;
            }
            // delete last selector
            ds.selectors.pop();
            delete ds.facetAddressAndSelectorPosition[selector];
        }
    }
}
