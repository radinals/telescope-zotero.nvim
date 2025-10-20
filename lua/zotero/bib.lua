-- (Crudely) Locates the bibliography
--
--
local biblatex = require("zotero.translation.biblatex")
local bibtex = require("zotero.translation.bibtex")

local M = {}

M.quarto = {}
M.tex = {}
M['quarto.cached_bib'] = nil

M.locate_quarto_bib = function()
  if M['quarto.cached_bib'] then
    return M['quarto.cached_bib']
  end
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  for _, line in ipairs(lines) do
    local location = string.match(line, [[bibliography:[ "']*(.+)["' ]*]])
    if location then
      M['quarto.cached_bib'] = location
      return M['quarto.cached_bib']
    end
  end
  -- no bib locally defined
  -- test for quarto project-wide definition
  local fname = vim.api.nvim_buf_get_name(0)

  -- Iterate up the directory tree to find the _quarto.yml file
  local function find_quarto_root(start_path)
    local current = vim.fn.fnamemodify(start_path, ':p:h')
    local previous = nil
    while current ~= previous do
      local config_file = current .. '/_quarto.yml'
      if vim.fn.filereadable(config_file) == 1 then
        return current
      end
      previous = current
      current = vim.fn.fnamemodify(current, ':h')
    end
    return nil
  end

  local root = find_quarto_root(fname)
  if root then
    local file = root .. '/_quarto.yml'
    for line in io.lines(file) do
      local location = string.match(line, [[bibliography:[ "']*(.+)["' ]*]])
      if location then
        M['quarto.cached_bib'] = location
        return M['quarto.cached_bib']
      end
    end
  end
end

local function resolve_includes(file_path, resolved_lines)
  local lines = vim.fn.readfile(file_path)
  for _, line in ipairs(lines) do
    local include_path = string.match(line, '^include::(.-)%[%]$')
    if include_path then
      local full_path = vim.fn.fnamemodify(include_path, ':p')
      resolve_includes(full_path, resolved_lines)
    else
      table.insert(resolved_lines, line)
    end
  end
end

M.locate_asciidoc_bib = function()
  if M['asciidoc.cached_bib'] then
    return M['asciidoc.cached_bib']
  end

  local current_file = vim.fn.expand '%:p'
  local resolved_lines = {}
  resolve_includes(current_file, resolved_lines)

  local temp_file = vim.fn.tempname()
  vim.fn.writefile(resolved_lines, temp_file)

  for _, line in ipairs(resolved_lines) do
    local location = string.match(line, [[:bibliography-database:[ "']*(.+)["' ]*]])
    if location then
      M['asciidoc.cached_bib'] = location
      return M['asciidoc.cached_bib']
    end
    local location = string.match(line, [[:bibtex-file:[ "']*(.+)["' ]*]])
    if location then
      M['asciidoc.cached_bib'] = location
      return M['asciidoc.cached_bib']
    end
  end

  -- no bib locally defined, default to `references.bib`
  return 'references.bib'
end

M.locate_tex_bib = function()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  for _, line in ipairs(lines) do
    -- ignore commented bibliography
    local comment = string.match(line, '^%%')
    if not comment then
      local location = string.match(line, [[\bibliography{[ "']*([^'"\{\}]+)["' ]*}]])
      if location then
        return location .. '.bib'
      end
      -- checking for biblatex
      location = string.match(line, [[\addbibresource{[ "']*([^'"\{\}]+)["' ]*}]])
      if location then
        -- addbibresource optionally allows you to add .bib
        return location:gsub('.bib', '') .. '.bib'
      end
    end
  end
end

M.locate_typst_bib = function()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  for _, line in ipairs(lines) do
    local location = line:match("^#bibliography%((.+)%)")
    if location then
      return location:sub(2,-2)
    end
  end
  return "references.bib"
end

M.locate_org_bib = function()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  for _, line in ipairs(lines) do
    local location = line:match("#%+BIBLIOGRAPHY:%s*(.+)") or line:match("#%+bibliography:%s*(.+)")
    if location then
      return location
    end
  end
  return "references.bib"
end

local getLatexBibType = function()
  vim.api.nvim_win_set_cursor(0, {1, 1})
  if (vim.fn.search("\\V\\\\bibliography", "nw") ~= 0) then
    return "bibtex"
  elseif (vim.fn.search("\\V\\\\addbibresource", "nw") ~= 0 or vim.fn.search("\\V\\\\printbibliography", "nw") ~= 0 ) then
    return "biblatex"
  end
end

M.entry_to_bib_entry = function(entry)
  local bib_entry = '@'
  local item = entry.value
  local citekey = item.citekey or ''

  local itemType = item.itemType

  vim.notify("Zotero returned ".. itemType .. "")

  if (getLatexBibType() == "biblatex") then
    itemType = biblatex(itemType)
    vim.notify("detected biblatex format",vim.log.levels.INFO)
  vim.notify("itemType translated to " .. itemType )
  elseif(getLatexBibType() == "bibtex") then
    itemType = bibtex(itemType)
    vim.notify("detected bibtex format", vim.log.levels.INFO)
  vim.notify("itemType translated to " .. itemType )
  elseif(vim.bo.filetype == "tex") then
    itemType = bibtex(itemType)
    vim.notify("cannot detect bibliography format, fallback to bibtex", vim.log.levels.INFO)
    vim.notify("itemType translated to " .. itemType )
  end


  bib_entry = bib_entry .. (itemType or " ") .. '{' .. citekey .. ',\n'

  for k, v in pairs(item) do
    if k == 'creators' then
      bib_entry = bib_entry .. '  author = {'
      local author = ''
      for _, creator in ipairs(v) do
        author = author .. (creator.lastName or '') .. ', ' .. (creator.firstName or '') .. ' and '
      end
      -- remove trailing ' and '
      author = string.sub(author, 1, -6)
      bib_entry = bib_entry .. author .. '},\n'
    elseif k ~= 'citekey' and k ~= 'itemType' and k ~= 'attachment' and type(v) == 'string' then
      bib_entry = bib_entry .. '  ' .. k .. ' = {' .. v .. '},\n'
    end
  end
  bib_entry = bib_entry .. '}\n'
  return bib_entry
end

return M
