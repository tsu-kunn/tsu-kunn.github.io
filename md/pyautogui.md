I'm sorry in Japanese.


# 検索画像が画面外の場合はスクロールさせる
検索した画像が画面にない場合は、表示画面より下にいることがわかっているので、
検索結果が None だった場合は pagedown キーでスクロールさせる。
何回繰り返すかは引数で渡すことができる。（defalt: 2)

pagedown は引数で指定できるようにしてもよいと思います。  
(環境により移動のさせ方が違うこともあるため)

## sample code #1
~~~python
def LocateOnScreen(path, confidence = 0.9):
    try:
        # You need to have OpenCV installed for the confidence keyword to work.
        locate = pyautogui.locateOnScreen(path, grayscale=True, confidence=confidence, region=(app_x, app_y, app_w, app_h))
        return locate

    except ImageNotFoundException:
        print(path + " not found!\n")
        return None

    except pyautogui.ImageNotFoundException:
        print(path + " not found!\n")
        return None

def pictureSearch(path, rep = 2, confidence = 0.9):
    for i in range(rep):
        locate = LocateOnScreen(path, confidence)
        print("pictSearch: " + path)
        print(locate)

        if locate == None:
            pyautogui.keyDown("pagedown")
            time.sleep(0.3)
        else:
            break

    return locate
~~~

# リストが数字の場合
リストが数字の場合は、数字キーを押下することでその項目に移動できる。
これを利用して、設定したい値から押下する数字キーと回数を求める。

ex:  
0の場合は 0  
1の場合は 1, 10, 11, 12, 13...

## sample code #2
~~~python
def numberListSelect(num, max):
    click_cnt = 0
    press_key = None

    if num > max:
        pass

    elif num < 10:
        click_cnt = 1
        press_key = str(num)

    elif num < 20:
        click_cnt = num - 10 + 2
        press_key = "1"

    elif num < 30:
        click_cnt = num - 20 + 2
        press_key = "2"

    elif num < 40:
        click_cnt = num - 30 + 2
        press_key = "3"

    elif num < 50:
        click_cnt = num - 40 + 2
        press_key = "4"

    elif num < 60:
        click_cnt = num - 50 + 2
        press_key = "5"

    elif num == 60:
        click_cnt = 2
        press_key = "6"

    return click_cnt, press_key

def mouseMoveToClick(locate, ofsX = 0, ofsY = 0, duration=0):
    if locate != None:
        x, y = pyautogui.center(locate)
        # print("x: " + str(x + ofsX) + ", y: " + str(y + ofsY))
        pyautogui.moveTo(x + ofsX, y + ofsY, duration)
        pyautogui.click()


# list show
locate = pictureSearch("picture path")
mouseMoveToClick(locate)

# start from "0"
pyautogui.press("0")
pyautogui.press("enter")

# get click count & press key number
click_cnt, press_key = numberListSelect(32, 59)

# list show again
locate = pictureSearch("picture path")
mouseMoveToClick(locate)

# setting number
for i in range(click_cnt):
    pyautogui.press(press_key)

pyautogui.press("enter")
~~~

# リストが文字列の場合
- 数が少ない場合  
項目数分だけ認識させる画像を用意して回避。
リストがスクロールする場合は、画像検索して取得できなかった場合は、**カーソルキー** でスクロールさせて対応しました。

- 数が多い場合
リストデフォルト値を固定とし、必ず表示される文字列を基準としてY座標を取得し、どちらに表示されたのかを判断する。  
それに加えて、基準となる項目の画像を複数用意し、それが検索できるまで**カーソルキー**でスクロールさせて対応しました。
（力技になっているので、決して良い案ではないですが）
