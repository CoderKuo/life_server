/*
 * fn_miscMapper.sqf
 * Misc Data Access Layer - Router
 * Loads and caches the full mapper code at runtime to avoid CfgFunctions compilation size limit
 */

// Check if full mapper is already loaded/cached
if (isNil "DB_miscMapper_code") then {
    // Load full mapper code from external file
    DB_miscMapper_code = compile preprocessFileLineNumbers "\life_server\Functions\Database\Mappers\miscMapper_impl.sqf";
    diag_log "[MiscMapper] Loaded implementation from external file";
};

// Execute the full mapper with parameters
_this call DB_miscMapper_code
