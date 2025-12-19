local v = import '../internal/validation.libsonnet';
/**
  MEMORY LIMITS

  Limits and requests for memory are measured in bytes.

  Supported suffixes:
    - Decimal: E, P, T, G, M, k
    - Binary: Ei, Pi, Ti, Gi, Mi, Ki
*/

// Helper to capture the allowed memory suffixes (longer suffixes first)
local memSuffixes = ['Ei', 'Pi', 'Ti', 'Gi', 'Mi', 'Ki', 'E', 'P', 'T', 'G', 'M', 'k'];

// Check if string is a valid number (digits only, with optional decimal)
local isNumericString(s) =
  local chars = std.stringChars(s);
  std.length(s) > 0 && std.all([
    c == '.' || (c >= '0' && c <= '9')
    for c in chars
  ]);

// Get the memory suffix if present
local getMemorySuffix(mem) =
  local matches = [suffix for suffix in memSuffixes if std.endsWith(mem, suffix)];
  if std.length(matches) > 0 then matches[0] else null;

// Validate memory input
local validateMemory(memory) =
  if memory == null then
    {}
  else if std.isNumber(memory) then
    if memory < 0 then error 'memory must be a positive number' else {}
  else if std.isString(memory) then
    local suffix = getMemorySuffix(memory);
    if suffix == null then
      error 'memory must have a valid suffix: ' + std.join(', ', memSuffixes)
    else
      local numPart = std.substr(memory, 0, std.length(memory) - std.length(suffix));
      if !isNumericString(numPart) then
        error 'memory value "%s" is invalid - must be a number followed by exactly one suffix' % memory
      else {}
  else
    error 'memory must be a string or number';

// Validate CPU input (can be number, string number like '1', or millicores like '100m')
local validateCPU(cpu) =
  if cpu == null then
    {}
  else if std.isNumber(cpu) then
    if cpu < 0 then error 'cpu must be a positive number' else {}
  else if std.isString(cpu) then
    if std.endsWith(cpu, 'm') then
      local numPart = std.substr(cpu, 0, std.length(cpu) - 1);
      if !isNumericString(numPart) then
        error 'cpu value "%s" is invalid,  must be a number followed by "m" or just a number' % cpu
      else {}
    else if isNumericString(cpu) then
      {}  // Plain number string like '1' or '0.5' is valid
    else
      error 'cpu must be a natural number or end with "m" suffix (e.g., "100m", "0.5", "1")'
  else
    error 'cpu must be a string or number';

{
  resources: {
    /**
    Set resource requests for the application container.
    Requests define the minimum amount of resources the container needs.

    Variables:
     - cpu: string - CPU request
     - memory: string - Memory request
    */
    withRequests(cpu=null, memory=null)::
      validateMemory(memory) +
      validateCPU(cpu) + 
      {
        application+: {
          spec+: {
            resources+: {
              requests: std.prune({
                cpu: cpu,
                memory: memory,
              }),
            },
          },
        },
      },

    /**
    Set resource limits for the application container.
    Limits define the maximum amount of resources the container can use.

    Variables:
     - cpu: string - CPU limit
     - memory: string - Memory limit
    */
    withLimits(cpu=null, memory=null)::
      validateMemory(memory) +
      validateCPU(cpu) +
      {
        application+: {
          spec+: {
            resources+: {
              limits: std.prune({
                cpu: cpu,
                memory: memory,
              }),
            },
          },
        },
      },
  },
}
