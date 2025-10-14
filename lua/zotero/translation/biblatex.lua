local translations = []
translations['article'] = 'article'
translations['article-journal'] = 'article'
translations['article-magazine'] = { type = 'article', subtype = 'magazine' }
translations['article-newspaper'] = { type = 'article', subtype = 'newspaper' }
translations['bill'] = 'legislation'
translations['book'] = 'book'
translations['broadcast'] = { type = 'misc', subtype = 'broadcast' }
translations['chapter'] = 'incollection'
translations['data'] = 'dataset'
translations['dataset'] = 'dataset'
translations['entry'] = 'inreference'
translations['entry-dictionary'] = 'inreference'
translations['entry-encyclopedia'] = 'inreference'
translations['figure'] = 'image'
translations['graphic'] = 'image'
translations['interview'] = { type = 'misc', subtype = 'interview' }
translations['legal_case'] = 'jurisdiction'
translations['legislation'] = 'legislation'
translations['manuscript'] = 'unpublished'
translations['map'] = { type = 'misc',subtype = 'map' }
translations['motion_picture'] = 'movie'
translations['musical_score'] = 'audio'
translations['pamphlet'] = 'booklet'
translations['paper-conference'] = 'inproceedings'
translations['patent'] = 'patent'
translations['personal_communication'] = 'letter'
translations['post'] = 'online'
translations['post-weblog'] = 'online'
translations['report'] = 'report'
translations['review'] = 'review'
translations['review-book'] = 'review'
translations['song'] = 'music'
translations['speech'] = { type = 'misc', subtype = 'speech' }
translations['thesis'] = 'thesis'
translations['treaty'] = 'legal'
translations['webpage'] = 'online'
translations['artwork'] = 'artwork'
translations['audioRecording'] = 'audio'
translations['bill'] = 'legislation'
translations['blogPost'] = 'online'
translations['book'] = 'book'
translations['bookSection'] = 'incollection'
translations['case'] = 'jurisdiction'
translations['computerProgram'] = 'software'
translations['conferencePaper'] = 'inproceedings'
translations['dictionaryEntry'] = 'inreference'
translations['dataset'] = 'dataset'
translations['document'] = 'misc'
translations['email'] = 'letter'
translations['encyclopediaArticle'] = 'inreference'
translations['film'] = 'video'
translations['forumPost'] = 'online'
translations['gazette'] = 'jurisdiction'
translations['hearing'] = 'jurisdiction'
translations['instantMessage'] = 'misc'
translations['interview'] = 'misc'
translations['journalArticle'] = 'article'
translations['letter'] = 'letter'
translations['magazineArticle'] = { type = 'article', subtype = 'magazine' }
translations['manuscript'] = 'unpublished'
translations['map'] = 'misc'
translations['newspaperArticle'] = { type = 'article', subtype = 'newspaper' }
translations['patent'] = 'patent'
translations['podcast'] = 'audio'
translations['preprint'] = 'online'
translations['presentation'] = 'unpublished'
translations['radioBroadcast'] = 'audio'
translations['report'] = 'report'
translations['standard'] = 'standard'
translations['statute'] = 'legislation'
translations['thesis'] = 'thesis'
translations['tvBroadcast'] = 'video'
translations['videoRecording'] = 'video'
translations['webpage'] = 'online'


return function translateToBiblatex(type)
  local translation = translations[type]

  local translated = ""

  if (translation.type)
    translated = translated .. translation.type
  end

  if (translation.subtype)
    translated = translated .. "[" .. translation.subtype .. "]"
  end

  return translated
end




