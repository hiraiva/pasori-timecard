# encoding: utf-8

require "pasori"

class TimecardController < ApplicationController
  def index
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def scan
    @kind = params[:kind]
    @idm = params[:idm]
    @name = params[:name]

    if @name.present?
      @member = Member.new({:idm => @idm, :name => @name})
      @member.save
    else
      @idm = scan_idm
      if (@idm.blank?)
        flash[:notice] = "ICカードの読み取りに失敗しました"
        redirect_to :action => "index"
        return
      end

      if (Member.exists?(:idm => @idm))
        @member = Member.find(:first, :conditions => ["idm = ?", @idm])
      else
        @member = Member.new
      end
    end

    if (@member.idm.blank?)
      respond_to do |format|
        format.html # scan.html.erb
      end
    else
      MemberTime.create({:member_id => @member.id, :kind => @kind})

      case @kind.to_i
      when 1
        mes = @member.name + " さん、おはようございます！"
      when 2
        mes = @member.name + " さん、お疲れ様でした！"
      when 11
        mes = @member.name + " さん、いってらっしゃい！"
      when 12
        mes = @member.name + " さん、おかえりなさい！"
      end

      flash[:notice] = mes
      redirect_to :action => "index"
    end
  end

  private
  def scan_idm
    begin
      Pasori.open {|pasori|
        felica = pasori.felica_polling(Felica::POLLING_SUICA)
        if (felica.nil?)
          felica = pasori.felica_polling(Felica::POLLING_IRUCA)
        end

        return "" if (felica.blank?)

        return felica.idm.unpack("H").join("").force_encoding('utf-8')
      }
    rescue
      return ""
    end
  end
end
