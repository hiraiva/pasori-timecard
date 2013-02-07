# encoding: utf-8

require "pasori"
require "date"
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
        flash[:mes] = "ICカードの読み取りに失敗しました"
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
        format.html # new.html.erb
      end
    else
      member_time = MemberTime.create({:member_id => @member.id, :kind => @kind})

      name = @member.name.force_encoding('utf-8')
      @mes = ""
      @mes_sub = ""
      case @kind.to_i
      when 1
        @mes = name + " さん、おはようございます！"
      when 2
        last_member_time = MemberTime.find(:first, :conditions => ["member_id = ? AND (kind = 1 OR kind = 21)", @member.id], :order => "created_at DESC")
        if (last_member_time.present?)
          costed_time = (member_time.created_at - last_member_time.created_at).to_i
          @mes = name + " さん、お疲れ様でした！"
          @mes_sub = "勤務時間は " + (costed_time / 3600).to_s + "時間" + (costed_time % 3600 / 60).to_s + "分 です"
        else
          @mes = name + " さん、お疲れ様でした！"
        end
      when 11
        @mes = name + " さん、いってらっしゃい！"
      when 12
        last_member_time = MemberTime.find(:first, :conditions => ["member_id = ? AND kind = 11", @member.id], :order => "created_at DESC")
        if (last_member_time.present?)
          costed_time = (member_time.created_at - last_member_time.created_at).to_i
          @mes = name + " さん、おかえりなさい！"
          @mes_sub = "外出時間は " + (costed_time / 3600).to_s + "時間" + (costed_time % 3600 / 60).to_s + "分 です"
        else
          @mes = name + " さん、おかえりなさい！"
        end
      end

      @times_by_date = get_times_by_date(@member)
      @date_format = "%Y-%m-%d %H:%M:%S"
    end
  end

  def list
    @idm = scan_idm

    if (@idm.blank?)
      flash[:mes] = "ICカードの読み取りに失敗しました"
      redirect_to :action => "index"
      return
    end

    if (Member.exists?(:idm => @idm))
      @member = Member.find(:first, :conditions => ["idm = ?", @idm])
    else
      flash[:mes] = "まだ登録されていないICカードです"
      redirect_to :action => "index"
      return
    end

    @times_by_date = get_times_by_date(@member)
  end

  def list_by_id
    @id = params[:id]

    if (Member.exists?(:id => @id))
      @member = Member.find(:first, :conditions => ["id = ?", @id])
    else
      flash[:mes] = "まだ登録されていないICカードです"
      redirect_to :action => "index"
      return
    end

    @times_by_date = get_times_by_date(@member)
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
          return felica.idm.unpack("H*").join("").force_encoding("utf-8")
        else
          return nil
        end
      }
    rescue
      return nil
    end
  end

  def get_times_by_date(member)
    nums = 14
    by_date = {}
    nums.times do |n|
      target_date = (DateTime.now - n)
      data = {}
      MemberTime.find(:all, {:conditions => ["member_id = ? AND DATE(created_at) = ?", member.id, target_date.strftime("%Y-%m-%d")], :order => "created_at DESC"}).each do |row|
        data[row.kind] = row
      end
      by_date[target_date] = data
    end
    return by_date
  end
end