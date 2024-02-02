function opponentNoteHit(note:Note)
{
    game.opponentStrums.members[note.noteData].playAnim("static", true);
}