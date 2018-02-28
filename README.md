
# LTR Baseline

A collection of LTR baselines using various algorithms from publicly availble implementations.

## Results

### Yahoo! Set 1

| Ranker     | Framework | RBP@0.8 | RBP@0.9 | ERR@5   | ERR@10  | ERR@20  | NDCG@5  | NDCG@10 | NDCG@20 |
|------------|-----------|---------|---------|---------|---------|---------|---------|---------|---------|
| GBDT       | XGBoost   | 0.7685  | 0.6409  | 0.4600  | 0.4745  | 0.4783  | 0.7439  | 0.7858  | 0.8272  |
| LambdaRank | LGBM      | 0.7653  | 0.6379  | 0.4616  | 0.4761  | 0.4799  | 0.7425  | 0.7845  | 0.8253  |
| LambdaRank | jforests  | 0.7650  | 0.6377  | 0.4615  | 0.4760  | 0.4798  | 0.7431  | 0.7842  | 0.8256  |
| LambdaMART | QuickRank | 0.7645  | 0.6372  | 0.4603  | 0.4749  | 0.4787  | 0.7408  | 0.7827  | 0.8237  |
| X-DART     | QuickRank | 0.7582  | 0.6332  | 0.4546  | 0.4695  | 0.4735  | 0.7237  | 0.7688  | 0.8124  |


### MSLR-WEB10K

| Ranker     | Framework | RBP@0.8 | RBP@0.9 | ERR@5   | ERR@10  | ERR@20  | NDCG@5  | NDCG@10 | NDCG@20 |
|------------|-----------|---------|---------|---------|---------|---------|---------|---------|---------|
| LambdaRank | LGBM      | 0.6886  | 0.6353  | 0.3548  | 0.3735  | 0.3815  | 0.4724  | 0.4913  | 0.5225  |
| LambdaRank | jforests  | 0.6832  | 0.6306  | 0.3536  | 0.3724  | 0.3804  | 0.4672  | 0.4865  | 0.5180  |
