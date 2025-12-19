/**
  MEMORY LIMITS

  Limits and requests for memory are measured in bytes.

  Supported suffixes:
    - Decimal: E, P, T, G, M, k
    - Binary: Ei, Pi, Ti, Gi, Mi, Ki
*/

// Helper to capture the allowed memory suffixes (longer suffixes first)
local memSuffixes = ['Ei', 'Pi', 'Ti', 'Gi', 'Mi', 'Ki', 'E', 'P', 'T', 'G', 'M', 'k'];

// Validate if string contains only digits and optional single decimal point
local isNumericString(s, allowDecimal=true) =
  local chars = std.stringChars(s);
  local digitChars = std.filter(function(c) c >= '0' && c <= '9', chars);
  local dotCount = std.length(std.filter(function(c) c == '.', chars));
  !std.startsWith(s, "-")
  && std.length(digitChars) > 0
  && (if allowDecimal then dotCount <= 1 else dotCount == 0)
  && std.length(chars) - std.length(digitChars) <= (if allowDecimal then 1 else 0);

// Get the memory suffix if present
local getMemorySuffix(mem) =
  local matches = [suffix for suffix in memSuffixes if std.endsWith(mem, suffix)];
  if std.length(matches) > 0 then matches[0] else null;

// Extract numeric part before suffix
local getNumericPart(value, suffix) =
  std.substr(value, 0, std.length(value) - std.length(suffix));

// Validate memory input
local validateMemory(memory) =
  if memory == null then {}
  else if std.isNumber(memory) then
    if memory < 0 then error 'memory must be a positive number' else {}
  else if std.isString(memory) then
    local suffix = getMemorySuffix(memory);
    if suffix == null then
      error 'memory must have a valid suffix: ' + std.join(', ', memSuffixes)
    else
      local numPart = getNumericPart(memory, suffix);
      if !isNumericString(numPart, allowDecimal=false) then
        error 'memory value "%s" is invalid - must be a number followed by exactly one suffix' % memory
      else {}
  else error 'memory must be a string or number';

// Validate CPU input
local validateCPU(cpu) =
  if cpu == null then {}
  else if std.isNumber(cpu) then
    if cpu < 0 then error 'cpu must be a positive number' else {}
  else if std.isString(cpu) then
    if std.endsWith(cpu, 'm') then
      local numPart = getNumericPart(cpu, 'm');
      if !isNumericString(numPart, allowDecimal=true) then
        error 'cpu value "%s" is invalid - must be a number followed by "m"' % cpu
      else {}
    else if isNumericString(cpu, allowDecimal=true) then {}
    else
      error 'cpu must be a positive number or end with "m" suffix (e.g., "100m", "0.5")'
  else error 'cpu must be a string or number';

{
  resources: {
    /**
    Set resource requests for the application container.
    Requests define the minimum amount of resources the container needs.

    Variables:
     - cpu: string or number - CPU request
     - memory: string or number - Memory request
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
     - cpu: string or number - CPU limit
     - memory: string or number - Memory limit
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
