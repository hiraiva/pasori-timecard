# encoding: utf-8

require "pasori"
require "time"

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
      member_time = MemberTime.create({:member_id => @member.id, :kind => @kind})

      name = @member.name.force_encoding('utf-8')
      case @kind.to_i
      when 1
        mes = name + " さん、おはようございます！"
      when 2
        last_member_time = MemberTime.find(:first, :conditions => ["member_id = ? AND (kind = 1 OR kind = 21)", @member.id], :order => "created_at DESC")
        if (last_member_time.present?)
          costed_time = (member_time.created_at - last_member_time.created_at).to_i
          mes = name + " さん、お疲れ様でした！"
          mes_sub = "勤務時間は " + (costed_time / 3600).to_s + "時間" + (costed_time % 3600 / 60).to_s + "分 です"
        else
          mes = name + " さん、お疲れ様でした！"
        end
      when 11
        mes = name + " さん、いってらっしゃい！"
      when 12
        last_member_time = MemberTime.find(:first, :conditions => ["member_id = ? AND kind = 11", @member.id], :order => "created_at DESC")
        if (last_member_time.present?)
          costed_time = (member_time.created_at - last_member_time.created_at).to_i
          mes = name + " さん、おかえりなさい！"
          mes_sub = "外出時間は " + (costed_time / 3600).to_s + "時間" + (costed_time % 3600 / 60).to_s + "分 です"
        else
          mes = name + " さん、おかえりなさい！"
        end
      end

      flash[:mes] = mes
      flash[:mes_sub] = mes_sub if (mes_sub.present?)
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

        if (felica.present?)
          return felica.idm.unpack("H*").join("").force_encoding('utf-8')
        else
          return nil
        end
      }
    rescue
      return nil
    end
  end
end
