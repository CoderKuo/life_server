/*
 * fn_gangMapper.sqf
 * Gang Data Access Layer - Router
 * Loads and caches the full mapper code at runtime to avoid CfgFunctions compilation size limit
 */

// Check if full mapper is already loaded/cached
if (isNil "DB_gangMapper_code") then {
    // Load full mapper code from external file
    DB_gangMapper_code = compile preprocessFileLineNumbers "\life_server\Functions\Database\Mappers\gangMapper_impl.sqf";
    diag_log "[GangMapper] Loaded implementation from external file";
};

// Execute the full mapper with parameters
_this call DB_gangMapper_code
