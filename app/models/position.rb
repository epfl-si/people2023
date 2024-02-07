# frozen_string_literal: true

class Position
  attr_reader :id, :label_en, :label_frm, :label_fri, :label_frf

  include Translatable
  inclusively_translates :label

  PROF_RE = /^Profess/i
  ENS_RE = /professeur honoraire|-ENS$/i

  def initialize(h)
    @id = h.key?('id') ? h['id'] : 0
    @label_en = h['labelen']
    @label_frm = h['labelfr']
    @label_fri = h.key?('labelinclusive') ? h['labelinclusive'] : h['labelfr']
    @label_frf = h.key?('labelxx') ? h['labelxx'] : h['labelfr']
  end

  # TODO: there must be a less silly way of doing this!
  def possibly_teacher?
    PROF_RE.match(@label_frm)
  end

  def enseignant?
    ENS_RE.match(@label_frm)
  end
end