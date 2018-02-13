# jupyter/datascience-notebook > NG > enxajt/rstudio(rocker/rstudio)
docker run -it --rm -p 8888:8888 jupyter/datascience-notebook
URL on stdout
New > R
Ctrl Enter

# 構築
```
docker build . -t jupyter-jp
docker run -d --name jupyter-jp -p 8888:8888 jupyter-jp
docker logs Jupyter-jp
```
Jupyter サーバーは単一ユーザーでの利用を想定しているので、パスワードは一種類のみの設定
複数人で利用するには JupyterHub 

# 分析
参考: 養成読本

## 線形回帰モデル
```
install.packages("ggplot2")
library(ggplot2)

body.data <- read.csv("body_sample.csv", header=T, stringsAsFactors=F)
ggplot(body.data, aes(x=height,y=weight,col=gender)) + 
  geom_point() +
  theme_bw(16) +
  geom_smooth(method="lm")

amount1.data <- read.csv("amount1.csv")
head(amount1.data)
summary(amount1.data)
ggplot(amount1.data, aes(x=invest,y=amount))+
  geom_point() +
  theme_bw(16) +
  geom_smooth(method="lm")
```

### summary
```
amount1.lm1 <- lm(amount~invest, data=amount1.data)
summary(amount1.lm1)
```
#### Residuals
残差（予測値と実績値の差）の分布を四分位数で表現
偏りがあるか否か
#### Coefficients
推定値、標準誤差、t値、p値
その傾きがどれくらいばらつくのか、統計的な有意性があるのか
#### Multiple R-squared
決定係数
1に近いほどこのモデルの当てはまりが良い
説明変数が増えると高くなる。
#### Adjusted R-squared
決定係数の自由度調整値
決定係数から説明変数の数の影響を除外した値

### 残差の傾向をつかむ
```
plot(amount1.lm1, which=1)
```
モデルの妥当性の確認
その後の分析への手がかり

#### 山のようなパターン
予測値が中ほどの値のときはうまくフィットしているが、両端ではフィットしていない
そこで、逓減するような曲線にするために、investを対数に変換
```
ggplot(amount1.data, aes(x=invest,y=amount))+
  geom_point() +
  theme_bw(16) +
  geom_smooth(method="lm", formula=y~log(x))

plot(amount1.lm1, which=1)
amount1.lm1 <- lm(amount~log(invest), data=amount1.data)
```
残差y=0の横線 : フィットした。

## ロジスティック回帰モデル
```
z <- data.frame(Titanic)
titanic.data <- data.frame(
  Class=rep(z$Class, z$Freq),
  Sex=rep(z$Sex, z$Freq),
  Age=rep(z$Age, z$Freq),
  Survived=rep(z$Survived, z$Freq))
titanic.logit <- glm(Survived~., data=titanic.data, family=binomial)
summary(titanic.logit)

install.packages("devtools")
library(devtools)
install_github("cran/epicalc")
library(epicalc)
logistic.display(titanic.logit, simplified=T)
```

## 決定木
```
install.packages("partykit")
library(rpart)
library(partykit)
titanic.rp <-rpart(Survived~., data=titanic.data)
plot(as.party(titanic.rp), tp_args=T)
```
上の条件ほど大きく影響する。

## 主成分分析
```
state.pca <- prcomp(state.x77[, 1:6], scale=T)
biplot(state.pca)
```

## MDS:多次元尺度法
対象感の距離だけを使ってXY座標に配置
```
install.packages("ggplot2")
library(ggplot2)

hdist <- read.table("HokkaidoCitiesMDS.tsv", header=F)
head(hdist)
hcities <- c("札幌", "旭川", "稚内", "釧路", "帯広", "室蘭", "函館", "小樽")
names(hdist) <- hcities
rownames(hdist) <- hcities
hdist.cmd <- cmdscale(hdist)
hdist.cmd.df <- as.data.frame(hdist.cmd)
hdist.cmd.df$city <- rownames(hdist.cmd.df)
names(hdist.cmd.df) <- c("x","y","city")
ggplot(hdist.cmd.df,aes(x=-x,y=-y,label=city)) +
  geom_text() +
  theme_bw(16)
```

## k-means
主成分分析で3つに分かれそうであったので、クラスタ数は3
```
state.pca <- prcomp(state.x77[, 1:6], scale=T)
state.km <- kmeans(scale(state.x77[,1:6]),3)
state.pca.df <- data.frame(state.pca$x)
state.pca.df$name <- rownames(state.pca.df)
state.pca.df$cluster <- as.factor(state.km$cluster)
ggplot(state.pca.df,aes(x=PC1,y=PC2,label=name,col=cluster)) + 
  geom_text() + 
  theme_bw(16)
```

## レーダーチャート
各クラスタの特徴をつかむ
```
install.packages("fmsb")
library(fmsb)
df <- as.data.frame(scale(state.km$centers))
dfmax <- apply(df, 2, max)+1
dfmin <- apply(df, 2, min)-1
df <- rbind(dfmax,dfmin,df)
radarchart(df,seg=5,plty=1,pcol=rainbow(3))
legend("topright",legend=1:3,col=rainbow(3),lty=1)
```

## 属性x訴求ポイント 反応の高い組み合わせを抽出
多変量テスト
重回帰分析

# python
```
import datetime
import bokeh.plotting as bplt
!pip install pandas-datareader
from pandas_datareader import data as web

bplt.output_notebook()

start = datetime.date(2014, 1, 1)
end = datetime.date.today()
df = web.DataReader('^N225', 'yahoo', start, end)
df.describe()

p = bplt.figure(title='日経平均', x_axis_type='datetime', plot_width=640, plot_height=320)
p.segment(df.index, df.High, df.index, df.Low, color='black')
bplt.show(p)
```

# bank-marketing
new > R
```
z <- data.frame(Titanic)
titanic.data <- data.frame(
  Class=rep(z$Class, z$Freq),
  Sex=rep(z$Sex, z$Freq),
  Age=rep(z$Age, z$Freq),
  Survived=rep(z$Survived, z$Freq))
titanic.logit <- glm(Survived~., data=titanic.data, family=binomial)
summary(titanic.logit)

install.packages("devtools")
library(devtools)
install_github("cran/epicalc")
library(epicalc)
logistic.display(titanic.logit, simplified=T)

install.packages("partykit")
library(rpart)
library(partykit)
titanic.rp <-rpart(Survived~., data=titanic.data)
plot(as.party(titanic.rp), tp_args=T)
```

```
t<-proc.time()

bank.data <- read.csv2("data-set_4521-records.csv")
head(bank.data)
bank.logit <- glm(y~., data=bank.data, family=binomial)
summary(bank.logit)

install.packages("devtools")
library(devtools)
install_github("cran/epicalc")
library(epicalc)
logistic.display(bank.logit, simplified=T)

install.packages("partykit")
library(rpart)
library(partykit)
bank.rp <-rpart(y~., data=bank.data)
options(repr.plot.width=50, repr.plot.height=40)
plot(as.party(bank.rp), tp_args=T)

proc.time()-t
```
